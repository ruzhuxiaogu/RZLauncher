//
//  RZAppLaunchTask2.m
//  Example
//
//  Created by tingdongli on 2020/8/17.
//  Copyright © 2020 tingdongli. All rights reserved.
//

#import "RZAppLaunchTask2.h"

@implementation RZAppLaunchTask2
- (BOOL)runForLaunchLife:(NSInteger)life{
    if (life == RZLaunchLife_DidBecomeActive) {
        NSLog(@"RZAppLaunchTask2 finished in Thread:%@", [NSThread currentThread]);
    }else if (life == RZLaunchLife_AppInitialization) {
        NSLog(@"RZLaunchLife_AppInitialization RZAppLaunchTask2 finished in Thread:%@", [NSThread currentThread]);
    }
    return YES;
}

- (NSArray<NSString *> *)runPredecessorsForLaunchLife:(NSInteger)life{
    return @[@"RZAppLaunchTask1"];
}

- (RZLaunchThread)runInThreadForLaunchLife:(NSInteger)life{
    if (life == RZLaunchLife_DidBecomeActive) {
        return RZLaunchThread_RunLoopWaiting;
    }
    return RZLaunchThread_Main;
}

- (BOOL)runImmediatelyForLaunchLife:(NSInteger)life{
    return NO;
}

@end
