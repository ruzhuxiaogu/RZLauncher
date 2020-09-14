//
//  RZMap.m
//  Mediator
//
//  Created by tingdongli on 2020/8/18.
//

#import "RZMapNode.h"

@implementation RZMapNode

- (instancetype)init
{
    self = [super init];
    if (self) {
        _predecessors = [NSMutableArray array];
        _successors = [NSMutableArray array];
    }
    return self;
}

@end
