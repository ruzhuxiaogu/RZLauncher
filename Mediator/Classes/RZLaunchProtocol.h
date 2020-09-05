//
//  RZLaunchProtocol.h
//  Mediator
//
//  Created by tingdongli on 2020/3/19.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, RZLaunchLife) {
    RZLaunchLife_Load = 0,
    RZLaunchLife_Constructor,
    RZLaunchLife_WillFinishLaunching,
    RZLaunchLife_DidFinishLaunchingBeforeHomeRender,
    RZLaunchLife_DidFinishLaunchingAfterHomeRender,
    RZLaunchLife_TaskAfterLaunching,
    RZLaunchLife_AppInitialization,
    RZLaunchLife_DidBecomeActive,
    RZLaunchLife_WillEnterForeground,
    RZLaunchLife_DidEnterBackground,
    RZLaunchLife_WillResignActive,
    RZLaunchLife_HomePageDidAppear,
    RZLaunchLife_HomePageDidActive,
    RZLaunchLife_Min = RZLaunchLife_Load,
    RZLaunchLife_Max = RZLaunchLife_HomePageDidActive,
};

typedef NS_ENUM(NSInteger, RZLaunchThread) {
    RZLaunchThread_Main,
    RZLaunchThread_Work,
    RZLaunchThread_RunLoopWaiting   //runloop 空闲
};

typedef NS_ENUM(NSInteger, RZLaunchPriority) {
    RZLaunchPriority_Auto = 0,
    RZLaunchPriority_Low = -1,
    RZLaunchPriority_High = 1,
};

NS_ASSUME_NONNULL_BEGIN

@protocol RZLaunchProtocol <NSObject>

/*
* 任务执行之前的操作
* @param life 生命周期
*/
- (void)operateBeforeRunLaunchLife:(NSInteger)life;
/*
 * 指定每个生命周期需要执行的操作
 * @param life 生命周期
 */
- (BOOL)runForLaunchLife:(NSInteger)life;
/*
* 任务执行之后的操作
* @param life 生命周期
*/
- (void)operateAfterRunLaunchLife:(NSInteger)life;

/*
* 获取任务执行的时间
* @param life 生命周期
*/
- (CFAbsoluteTime)getOperateTime;
/*
* 是否立即执行，若为否，会先加入队列，然后执行
* @param life 生命周期
*/
- (BOOL)runImmediatelyForLaunchLife:(NSInteger)life;

@optional

/*
* 指定启动任务的前驱，前驱完成后再执行该任务
* @param life 生命周期
*/
- (NSArray <NSString *> *)runPredecessorsForLaunchLife:(NSInteger)life;

/*
* 指定启动任务的执行优先级
* @param life 生命周期
*/
- (RZLaunchPriority)priorityForLaunchLife:(NSInteger)life;

/*
* 指定实例对象
*/
+ (instancetype)launcher;

/*
* 指定启动任务的执行线程
* @param life 生命周期
*/
- (RZLaunchThread)runInThreadForLaunchLife:(NSInteger)life;

@end

NS_ASSUME_NONNULL_END
