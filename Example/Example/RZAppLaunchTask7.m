//
//  RZAppLaunchTask7.m
//  Example
//
//  Created by tingdongli on 2020/8/17.
//  Copyright © 2020 tingdongli. All rights reserved.
//

#import "RZAppLaunchTask7.h"

@implementation RZAppLaunchTask7
- (BOOL)runForLaunchLife:(NSInteger)life{
    if (life == RZLaunchLife_DidBecomeActive) {
        NSLog(@"RZAppLaunchTask7 finished in Thread:%@", [NSThread currentThread]);
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
