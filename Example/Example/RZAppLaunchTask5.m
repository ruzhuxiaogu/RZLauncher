//
//  RZAppLaunchTask5.m
//  Example
//
//  Created by tingdongli on 2020/8/17.
//  Copyright © 2020 tingdongli. All rights reserved.
//

#import "RZAppLaunchTask5.h"

@implementation RZAppLaunchTask5
- (BOOL)runForLaunchLife:(NSInteger)life{
    if (life == RZLaunchLife_DidBecomeActive) {
        NSLog(@"RZAppLaunchTask5 finished in Thread:%@", [NSThread currentThread]);
    }
    return YES;
}

- (NSArray<NSString *> *)runPredecessorsForLaunchLife:(NSInteger)life{
    return @[@"RZAppLaunchTask3"];
}
@end
