//
//  RZAppLaunchTask6.m
//  Example
//
//  Created by tingdongli on 2020/8/17.
//  Copyright © 2020 tingdongli. All rights reserved.
//

#import "RZAppLaunchTask6.h"

@implementation RZAppLaunchTask6
- (BOOL)runForLaunchLife:(NSInteger)life{
    if (life == RZLaunchLife_DidBecomeActive) {
        NSLog(@"RZAppLaunchTask6 finished in Thread:%@", [NSThread currentThread]);
    }
    return YES;
}


- (RZLaunchThread)runInThreadForLaunchLife:(NSInteger)life{
    if (life == RZLaunchLife_DidBecomeActive) {
        return RZLaunchThread_Work;
    }
    return RZLaunchThread_Main;
}
@end
