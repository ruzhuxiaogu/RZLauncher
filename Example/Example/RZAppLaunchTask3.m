//
//  RZAppLaunchTask3.m
//  Example
//
//  Created by tingdongli on 2020/8/17.
//  Copyright © 2020 tingdongli. All rights reserved.
//

#import "RZAppLaunchTask3.h"

@implementation RZAppLaunchTask3
- (BOOL)runForLaunchLife:(NSInteger)life{
    if (life == RZLaunchLife_DidBecomeActive) {
        NSLog(@"RZAppLaunchTask3 finished in Thread:%@", [NSThread currentThread]);
    }else if (life == RZLaunchLife_AppInitialization) {
        NSLog(@"RZLaunchLife_AppInitialization RZAppLaunchTask3 finished in Thread:%@", [NSThread currentThread]);
    }
    return YES;
}

- (NSArray<NSString *> *)runPredecessorsForLaunchLife:(NSInteger)life{
    if (life == RZLaunchLife_DidBecomeActive) {
        return @[@"RZAppLaunchTask2"];
    }else if (life == RZLaunchLife_AppInitialization) {
        return @[@"RZAppLaunchTask4"];
    }
    return nil;
}

- (RZLaunchThread)runInThreadForLaunchLife:(NSInteger)life{
    return RZLaunchThread_Main;
}

- (BOOL)runImmediatelyForLaunchLife:(NSInteger)life{
    return YES;
}
@end
