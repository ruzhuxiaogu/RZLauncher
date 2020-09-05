//
//  RZAppLaunchBaseTask.m
//  Mediator
//
//  Created by tingdongli on 2020/5/15.
//

#import "RZAppLaunchBaseTask.h"

@interface RZAppLaunchBaseTask ()
@property(nonatomic, assign) CFAbsoluteTime operateTime;
@end

@implementation RZAppLaunchBaseTask

- (BOOL)runForLaunchLife:(NSInteger)life {
    return YES;
}

- (RZLaunchPriority)priorityForLaunchLife:(NSInteger)life{
    return RZLaunchPriority_Auto;
}

- (void)operateBeforeRunLaunchLife:(NSInteger)life{
    self.operateTime = CFAbsoluteTimeGetCurrent();
}

- (void)operateAfterRunLaunchLife:(NSInteger)life{
    self.operateTime = CFAbsoluteTimeGetCurrent() - self.operateTime;
}

- (CFAbsoluteTime)getOperateTime{
    return _operateTime;
}

- (BOOL)runImmediatelyForLaunchLife:(NSInteger)life{
    return NO;
}

@end
