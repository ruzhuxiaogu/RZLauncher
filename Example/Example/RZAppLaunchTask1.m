//
//  RZAppLaunchTask1.m
//  Example
//
//  Created by tingdongli on 2020/8/17.
//  Copyright © 2020 tingdongli. All rights reserved.
//

#import "RZAppLaunchTask1.h"

@implementation RZAppLaunchTask1
- (BOOL)runForLaunchLife:(NSInteger)life{
    if (life == RZLaunchLife_DidBecomeActive) {
        NSLog(@"RZAppLaunchTask1 finished in Thread:%@", [NSThread currentThread]);
    } else if (life == RZLaunchLife_AppInitialization) {
        NSLog(@"RZLaunchLife_AppInitialization RZAppLaunchTask1 finished in Thread:%@", [NSThread currentThread]);
    }
    return YES;
}


@end
