//
//  RZLauncher.m
//  Mediator
//
//  Created by tingdongli on 2020/3/19.
//

#import "RZLauncher.h"
#include <dlfcn.h>
#include <mach-o/dyld.h>
#include <mach-o/getsect.h>
#include <mach-o/ldsyms.h>
#include <mach-o/loader.h>
#import <objc/message.h>
#import <objc/runtime.h>
#import "RZMap.h"

const char* kRZLauncherSectionName = "RZLauncher";
const NSInteger RZMaxConcurrentOperationCount = 6;
 
NSArray<NSString*>* RZLaunchLoadConfiguration(const char* sectionName)
{
    NSMutableArray* configs = [NSMutableArray array];

    Dl_info info;
    dladdr(RZLaunchLoadConfiguration, &info);

#ifndef __LP64__
    const struct mach_header* mhp = (struct mach_header*)info.dli_fbase;
    unsigned long size = 0;
    uint32_t* memory = (uint32_t*)getsectiondata(mhp, SEG_DATA, sectionName, &size);
#else /* defined(__LP64__) */
    const struct mach_header_64* mhp = (struct mach_header_64*)info.dli_fbase;
    unsigned long size = 0;
    uint64_t* memory = (uint64_t*)getsectiondata(mhp, SEG_DATA, sectionName, &size);
#endif /* defined(__LP64__) */

    unsigned long counter = size / sizeof(void*);
    for (int idx = 0; idx < counter; ++idx) {
        char* string = (char*)memory[idx];
        @autoreleasepool {
            NSString *configName = [NSString stringWithUTF8String:string];
            if (configName) {
                [configs addObject:configName];
            }
        }
    }

    return configs;
}

__attribute__((constructor)) static void constructRZLauncher(void)
{
    [[RZLauncher sharedLauncher] onTrigger:RZLaunchLife_Constructor];
}

@interface RZLauncher () {
    NSMutableArray<id<RZLaunchProtocol>>* _launchTasks;
    NSMutableDictionary *_launchTaskReportDict;
    NSLock *_lock;
    NSLock *_blockOperationLock;
    NSOperationQueue *_commonConcurrentQueue;
    NSMutableDictionary<NSString *, NSDictionary *> *_launchTaskOperationDict;
    NSDictionary<NSString *, NSDictionary *> *_localPlistLaunchTasksDict;
}

@end

@implementation RZLauncher

+ (void)load
{
    [[RZLauncher sharedLauncher] onTrigger:RZLaunchLife_Load];
}

+ (instancetype)sharedLauncher
{
    static dispatch_once_t onceToken;
    static RZLauncher* launcher;
    dispatch_once(&onceToken, ^{
        launcher = [[self alloc] init];
        NSArray<NSString*>* registerTaskNames = RZLaunchLoadConfiguration(kRZLauncherSectionName);
        NSArray<NSString*>* LocalPlistLaunchTaskNames = [launcher loadLocalLaunchTasks];
        NSMutableArray *taskNames = [NSMutableArray array];
        [taskNames addObjectsFromArray:registerTaskNames];
        [taskNames addObjectsFromArray:LocalPlistLaunchTaskNames];
        
        for (NSString* name in taskNames) {
            [launcher registerLaunchTaskName:name];
        }
    });
    return launcher;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _launchTasks = [NSMutableArray array];
        _launchTaskReportDict = [NSMutableDictionary dictionary];
        _lock = [[NSLock alloc] init];
        _commonConcurrentQueue = [[NSOperationQueue alloc] init];
        _commonConcurrentQueue.maxConcurrentOperationCount = RZMaxConcurrentOperationCount;
        _launchTaskOperationDict = [NSMutableDictionary dictionary];
        _blockOperationLock = [[NSLock alloc] init];
    }

    return self;
}

- (NSArray *)loadLocalLaunchTasks
{
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:RZLocalLaunchConfigName ofType:@"plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        return @[];
    }
    
    _localPlistLaunchTasksDict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    NSArray<NSString *> *launchTasks = _localPlistLaunchTasksDict.allKeys;
    
    if (launchTasks && launchTasks.count > 0) {
        return launchTasks;
    }
    
    return @[];
}

- (void)registerLaunchTaskName:(NSString*)name
{
    Class taskClass = NSClassFromString(name);
    NSAssert([taskClass conformsToProtocol:@protocol(RZLaunchProtocol)], @"%@ does not conform to RZLaunchProtocol", name);

    if ([taskClass conformsToProtocol:@protocol(RZLaunchProtocol)]) {
        id<RZLaunchProtocol> task = nil;
        if ([taskClass respondsToSelector:@selector(launcher)]) {
            task = [taskClass launcher];
        } else {
            task = [[taskClass alloc] init];
        }
        if (task) {
            [_launchTasks addObject:task];
        }
    }
}

- (void)registerBlockOperationsWithLaunchLife:(NSInteger)launchLiftIndex{
    
    [_launchTasks enumerateObjectsUsingBlock:^(id<RZLaunchProtocol>  _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![task runImmediatelyForLaunchLife:launchLiftIndex]) {
            [self registerBlockWithTask:task withLaunchLife:launchLiftIndex];
        }
    }];
}


- (void)registerBlockWithTask:(id<RZLaunchProtocol>)task withLaunchLife:(NSInteger)launchLiftIndex{
    NSMutableDictionary *runLiftOperationDict = [NSMutableDictionary dictionary];
    NSString *taskKey = NSStringFromClass(task.class);
    if ([_launchTaskOperationDict.allKeys containsObject:taskKey]) {
        [runLiftOperationDict addEntriesFromDictionary:[_launchTaskOperationDict objectForKey:taskKey]];
    }
    __weak typeof(self) weakSelf = self;
    NSBlockOperation *liftOperation = [NSBlockOperation blockOperationWithBlock:^{
        if (weakSelf) {
            [weakSelf p_checkOperateBeforeAndRunWithTask:task launchLife:launchLiftIndex];
        }
        [task runForLaunchLife:launchLiftIndex];
        if (weakSelf) {
            [weakSelf p_checkOperateAfterAndRunWithTask:task launchLife:launchLiftIndex];
        }
    }];
    if (liftOperation) {
        [runLiftOperationDict setObject:liftOperation forKey:@(launchLiftIndex)];
    }
    
    [_blockOperationLock lock];
    [_launchTaskOperationDict setValue:runLiftOperationDict.copy forKey:taskKey];
    [_blockOperationLock unlock];
}

- (void)onTrigger:(NSInteger)type
{
    RZMap *map = [self p_creatMapWithLaunchLife:type];
    NSAssert(![map detectCircle], @"启动任务存在循环依赖！");
    if ([map detectCircle]) {
        return ;
    }
    
    //生成type对应的BlockOperation
    [self registerBlockOperationsWithLaunchLife:type];
    //增加依赖
    [self addDependencysWithLaunchLife:type];
    
    // 启动流程应该是串型的，所以这里不加锁处理
    NSMutableArray<id<RZLaunchProtocol>>* lowPriorityLaunchers = [NSMutableArray arrayWithCapacity:_launchTasks.count];
    NSMutableArray<id<RZLaunchProtocol>>* normalPriorityLaunchers = [NSMutableArray arrayWithCapacity:_launchTasks.count];
    NSMutableArray<id<RZLaunchProtocol>>* runloopWaitingLaunchers = [NSMutableArray arrayWithCapacity:_launchTasks.count];
    NSMutableArray<id<RZLaunchProtocol>>* deleteLaunchers = [NSMutableArray arrayWithCapacity:_launchTasks.count];
    [_launchTasks enumerateObjectsUsingBlock:^(id<RZLaunchProtocol> launcher, NSUInteger idx, BOOL* stop) {
        RZLaunchPriority priority = RZLaunchPriority_Auto;
        if ([launcher respondsToSelector:@selector(priorityForLaunchLife:)]) {
            priority = [launcher priorityForLaunchLife:type];
        }

        switch (priority) {
        case RZLaunchPriority_High:
            if ([self launchTaskNeedRunWhenRunLoopWaiting:launcher launchLife:type]) {
                [runloopWaitingLaunchers addObject:launcher];
            }else{
                [self runForLaunchLife:type forTask:launcher deleteArr:deleteLaunchers];
            }
            break;
        case RZLaunchPriority_Auto:
            [normalPriorityLaunchers addObject:launcher];
            break;
        case RZLaunchPriority_Low:
            [lowPriorityLaunchers addObject:launcher];
            break;
        default:
            break;
        }
    }];
    if (normalPriorityLaunchers.count > 0) {
        [normalPriorityLaunchers enumerateObjectsUsingBlock:^(id<RZLaunchProtocol> launcher, NSUInteger idx, BOOL* stop) {
            if ([self launchTaskNeedRunWhenRunLoopWaiting:launcher launchLife:type]) {
                [runloopWaitingLaunchers addObject:launcher];
            }else{
                [self runForLaunchLife:type forTask:launcher deleteArr:deleteLaunchers];
            }
        }];
    }
    if (lowPriorityLaunchers.count > 0) {
        [lowPriorityLaunchers enumerateObjectsUsingBlock:^(id<RZLaunchProtocol> launcher, NSUInteger idx, BOOL* stop) {
            if ([self launchTaskNeedRunWhenRunLoopWaiting:launcher launchLife:type]) {
                [runloopWaitingLaunchers addObject:launcher];
            }else{
                [self runForLaunchLife:type forTask:launcher deleteArr:deleteLaunchers];
            }
        }];
    }
    
    //runloop空闲执行
    if (runloopWaitingLaunchers && runloopWaitingLaunchers.count > 0) {
        CFRunLoopRef runLoop = CFRunLoopGetCurrent();
        CFStringRef runLoopMode = kCFRunLoopDefaultMode;
        CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, kCFRunLoopBeforeWaiting, true, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity _) {
            [runloopWaitingLaunchers enumerateObjectsUsingBlock:^(id<RZLaunchProtocol> launcher, NSUInteger idx, BOOL* stop) {
                
                if ([launcher runImmediatelyForLaunchLife:type]) {
                    [self p_checkOperateBeforeAndRunWithTask:launcher launchLife:type];
                    [launcher runForLaunchLife:type];
                    [self p_checkOperateAfterAndRunWithTask:launcher launchLife:type];
                }else{
                    NSDictionary *runThisTaskLifeOperationDict = [self->_launchTaskOperationDict objectForKey:NSStringFromClass(launcher.class)];
                    NSBlockOperation *runThisTaskLifeOperation = [runThisTaskLifeOperationDict objectForKey:@(type)];
                    
                    if (runThisTaskLifeOperation) {
                        [[NSOperationQueue mainQueue] addOperation:runThisTaskLifeOperation];
                    }
                }
                
            }];
            CFRunLoopRemoveObserver(runLoop, observer, runLoopMode);
            CFRelease(observer);
        });
        CFRunLoopAddObserver(runLoop, observer, runLoopMode);
    }

    
    
    if (deleteLaunchers.count > 0) {
        [_launchTasks removeObjectsInArray:deleteLaunchers];
    }
}

- (void)runForLaunchLife:(NSInteger)type forTask:(id<RZLaunchProtocol>)task deleteArr:(NSMutableArray<id<RZLaunchProtocol>>*)deleteArr{
    RZLaunchThread launchThread = RZLaunchThread_Main;
    if ([task respondsToSelector:@selector(runInThreadForLaunchLife:)]) {
        launchThread = [task runInThreadForLaunchLife:type];
    }
    
    NSDictionary *runThisTaskLifeOperationDict = [_launchTaskOperationDict objectForKey:NSStringFromClass(task.class)];
    NSBlockOperation *runThisTaskLifeOperation = [runThisTaskLifeOperationDict objectForKey:@(type)];
    
        if (launchThread == RZLaunchThread_Work) {
            if (runThisTaskLifeOperation) {
                [_commonConcurrentQueue addOperation:runThisTaskLifeOperation];
            }
        }else{
            //主线程
            if ([task runImmediatelyForLaunchLife:type]) {
                //需要立即执行
                [self p_checkOperateBeforeAndRunWithTask:task launchLife:type];
                [task runForLaunchLife:type];
                [self p_checkOperateAfterAndRunWithTask:task launchLife:type];
            }else{
                if (runThisTaskLifeOperation) {
                    [[NSOperationQueue mainQueue] addOperation:runThisTaskLifeOperation];
                }
            }
       }
}

- (void)addDependencysWithLaunchLife:(NSInteger)launchLifeIndex{
    [_launchTasks enumerateObjectsUsingBlock:^(id<RZLaunchProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([self p_getPredecessorsForTask:obj forLaunchLife:launchLifeIndex]) {
                NSArray *runPredecessors = [self p_getPredecessorsForTask:obj forLaunchLife:launchLifeIndex];
                if (runPredecessors && runPredecessors.count > 0) {
                    NSDictionary *runThisTaskLifeOperationDict = [_launchTaskOperationDict objectForKey:NSStringFromClass(obj.class)];
                    NSBlockOperation *runThisTaskLifeOperation = [runThisTaskLifeOperationDict objectForKey:@(launchLifeIndex)];
                    for (NSString *runPredecessorName in runPredecessors) {
                        NSDictionary *runPredecessorTaskLifeOperationDict = [_launchTaskOperationDict objectForKey:runPredecessorName];
                        NSBlockOperation *runPredecessorTaskLifeOperation = [runPredecessorTaskLifeOperationDict objectForKey:@(launchLifeIndex)];
                        if (runPredecessorTaskLifeOperation) {
                            [runThisTaskLifeOperation addDependency:runPredecessorTaskLifeOperation];
                        }
                    }
                }
            }
    }];
}

- (BOOL)launchTaskNeedRunWhenRunLoopWaiting:(id<RZLaunchProtocol>)task launchLife:(NSInteger)type{
    return [task respondsToSelector:@selector(runInThreadForLaunchLife:)] && [task runInThreadForLaunchLife:type] == RZLaunchThread_RunLoopWaiting;
}


- (NSDictionary *)getLaunchTaskReport{
    return _launchTaskReportDict.copy;
}


#pragma mark private method
- (void)p_checkOperateBeforeAndRunWithTask:(id<RZLaunchProtocol>)task launchLife:(NSInteger)type{
    if ([task respondsToSelector:@selector(operateBeforeRunLaunchLife:)]) {
        [task operateBeforeRunLaunchLife:type];
    }
}

- (void)p_checkOperateAfterAndRunWithTask:(id<RZLaunchProtocol>)task launchLife:(NSInteger)type{
    if ([task respondsToSelector:@selector(operateAfterRunLaunchLife:)]) {
        [task operateAfterRunLaunchLife:type];
        [self p_addToReportDictByTask:task launchLife:type];
    }
}

- (void)p_addToReportDictByTask:(id<RZLaunchProtocol>)task launchLife:(NSInteger)type{
    if (type == RZLaunchLife_DidFinishLaunchingBeforeHomeRender || type == RZLaunchLife_DidFinishLaunchingAfterHomeRender) {
        if ([task respondsToSelector:@selector(getOperateTime)]) {
            NSString *operateTimeStr = [NSString stringWithFormat:@"%lf", [task getOperateTime]];
            [_lock lock];
            [_launchTaskReportDict setValue:operateTimeStr forKey:NSStringFromClass(task.class)];
            [_lock unlock];
        }
    }
}

- (NSArray<NSString *> *)p_getPredecessorsForTask:(id<RZLaunchProtocol>)task forLaunchLife:(NSInteger)life{
    if ([task respondsToSelector:@selector(runPredecessorsForLaunchLife:)]) {
        NSArray *predecessors = [task runPredecessorsForLaunchLife:life];
        if (predecessors && predecessors.count > 0) {
            return predecessors;
        }
    }
    
    NSDictionary *lifePredecessorsDict = [_localPlistLaunchTasksDict objectForKey:NSStringFromClass(task.class)];
    NSString *liftStrKey = [NSString stringWithFormat:@"%@", @(life)];
    id lifePredecessors = [lifePredecessorsDict objectForKey: liftStrKey];
    if ([lifePredecessors isKindOfClass:[NSArray class]]) {
        NSArray *tLifePredecessors = lifePredecessors;
        if (tLifePredecessors && tLifePredecessors.count > 0) {
            return tLifePredecessors;
        }
    }
    
    return nil;
}

#pragma mark Map

- (RZMap *)p_creatMapWithLaunchLife:(NSInteger)type{
    RZMap *map = [[RZMap alloc] init];
    NSMutableArray<RZMapNode *> *mapNodeArr = [NSMutableArray array];
    [_launchTasks enumerateObjectsUsingBlock:^(id<RZLaunchProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        RZMapNode *node = [[RZMapNode alloc] init];
        node.valueStr = NSStringFromClass(obj.class);
        
        if ([self p_getPredecessorsForTask:obj forLaunchLife:type]) {
            NSArray *predecessors = [self p_getPredecessorsForTask:obj forLaunchLife:type];
            if (predecessors && predecessors.count > 0) {
                [node.predecessors addObjectsFromArray:predecessors];
            }
        }
        [mapNodeArr addObject:node];
    }];
    map.nodes = mapNodeArr.copy;
    
    [_launchTasks enumerateObjectsUsingBlock:^(id<RZLaunchProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([self p_getPredecessorsForTask:obj forLaunchLife:type]) {
            NSArray *predecessors = [self p_getPredecessorsForTask:obj forLaunchLife:type];
            if (predecessors && predecessors.count > 0) {
                for (NSString *predecessor in predecessors) {
                    RZMapNode *node = [map findMapNodeByValue:predecessor];
                    if (node) {
                        [node.successors addObject:NSStringFromClass(obj.class)];
                    }
                }
            }
        }
    }];
    return map;
}

@end

