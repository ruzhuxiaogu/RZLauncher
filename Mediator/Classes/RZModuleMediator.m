//
//  RZModuleMediator.m
//
//  Created by tingdongli on 2019/7/24.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import "RZModuleMediator.h"

@interface RZModuleMediator () {
    NSLock* _lock;
}

@property (nonatomic, strong) NSMutableDictionary* protocolCache;
@property (nonatomic, strong) NSMutableDictionary* impObjCache;

@end

@implementation RZModuleMediator

+ (instancetype)sharedInstance
{
    static RZModuleMediator* mediator = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mediator = [[RZModuleMediator alloc] init];
    });
    return mediator;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.protocolCache = [NSMutableDictionary dictionary];
        self.impObjCache = [NSMutableDictionary dictionary];
        _lock = [[NSLock alloc] init];
    }

    return self;
}

/*
 *      注册接口，把实现的Class注册到对应的Protocol上
 *      调用方根据Protocol查找到对应的Class，然后调用Class的方法 （这里一般是创建Class对象，然后调用这个对象实现的Protocol方法，进而根据接口编程）
 *
 */

- (void)registerProtocol:(Protocol*)protocol forClass:(Class)cls
{
    NSAssert(![self classForProtocol:protocol], ([NSString stringWithFormat:@"❌ %@不应该注册两次，请检查...", NSStringFromProtocol(protocol)]));
    [self.protocolCache setObject:cls forKey:NSStringFromProtocol(protocol)];
}

- (Class)classForProtocol:(Protocol*)protocol
{
    return self.protocolCache[NSStringFromProtocol(protocol)];
}

- (id)implForProtocol:(Protocol*)protocol
{
    NSString* key = NSStringFromProtocol(protocol);

    [_lock lock];
    Class cls = self.protocolCache[key];

    NSAssert(cls, ([NSString stringWithFormat:@"❌请检查调用的模块(%@)是否注册了实现类!", key]));

    id imp = self.impObjCache[key];
    if (!imp) {
        imp = [[cls alloc] init];
        [self.impObjCache setObject:imp forKey:key];
    }
    [_lock unlock];

    NSAssert(imp && [imp conformsToProtocol:protocol], @"❌ImpL 必须要遵从Protocol");
    NSAssert([imp conformsToProtocol:@protocol(RZModuleBaseProtocol)], @"❌ImpL 实现的Protocol必须从QBModuleBaseProtocol继承!");

    return imp;
}

+ (id)implObjForProtocol:(Protocol*)protocol
{
    return [[RZModuleMediator sharedInstance] implForProtocol:protocol];
}

@end
