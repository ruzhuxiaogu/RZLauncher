//
//  RZAppLaunchTask4.m
//  Example
//
//  Created by tingdongli on 2020/8/17.
//  Copyright © 2020 tingdongli. All rights reserved.
//

#import "RZAppLaunchTask4.h"

@implementation RZAppLaunchTask4
- (BOOL)runForLaunchLife:(NSInteger)life{
    if (life == RZLaunchLife_DidBecomeActive) {
        NSLog(@"RZAppLaunchTask4 finished in Thread:%@", [NSThread currentThread]);
    }else if (life == RZLaunchLife_AppInitialization) {
        NSLog(@"RZLaunchLife_AppInitialization RZAppLaunchTask4 finished in Thread:%@", [NSThread currentThread]);
    }
    return YES;
}

- (NSArray<NSString *> *)runPredecessorsForLaunchLife:(NSInteger)life{
    if (life == RZLaunchLife_DidBecomeActive) {
        return @[@"RZAppLaunchTask3"];
    }
    return nil;
}

- (RZLaunchThread)runInThreadForLaunchLife:(NSInteger)life{
    if (life == RZLaunchLife_AppInitialization) {
        return RZLaunchThread_Work;
    }
    return RZLaunchThread_Main;
}
@end
