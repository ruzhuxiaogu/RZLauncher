//
//  RZMap.m
//  Mediator
//
//  Created by tingdongli on 2020/8/19.
//

#import "RZMap.h"

@implementation RZMap

- (RZMapNode *)findMapNodeByValue:(NSString *)valueStr{
    return [self p_findMapNodeByValue:valueStr inArray:self.nodes];
}

- (BOOL)detectCircle{
    BOOL containsCircle = NO;
    NSMutableArray<RZMapNode *> *nodeArr = [NSMutableArray arrayWithArray:self.nodes];
    do {
        BOOL canFindNoPredecessorNode = [self p_findNoPredecessorsNodeAndDeleteInArray:nodeArr];
        
        if (nodeArr.count == 0) {
            break;
        }
        
        if (!canFindNoPredecessorNode && nodeArr.count > 0) {
            containsCircle = YES;
            break;
        }
        
    } while (true);
    
    return containsCircle;
}

- (BOOL)p_findNoPredecessorsNodeAndDeleteInArray:(NSMutableArray<RZMapNode *> *)nodeArr {
    NSInteger index = [nodeArr indexOfObjectPassingTest:^BOOL(RZMapNode * _Nonnull node, NSUInteger idx, BOOL * _Nonnull stop) {
        return node.predecessors.count == 0;
    }];
    
    if (index == NSNotFound) {
        return NO;
    }
    
    RZMapNode *node = [nodeArr objectAtIndex:index];
    if (node.successors.count > 0) {
        for (NSString *successor in node.successors) {
            RZMapNode *successorNode = [self p_findMapNodeByValue:successor inArray:nodeArr];
            if (successorNode && [successorNode.predecessors containsObject:node.valueStr]) {
                [successorNode.predecessors removeObject:node.valueStr];
            }
        }
    }
    [nodeArr removeObject:node];
    return YES;
}

- (RZMapNode *)p_findMapNodeByValue:(NSString *)valueStr inArray:(NSArray<RZMapNode *> *)nodeArr {
    NSInteger index = [nodeArr indexOfObjectPassingTest:^BOOL(RZMapNode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [valueStr isEqualToString:obj.valueStr];
    }];
    
    return index == NSNotFound ? nil : [nodeArr objectAtIndex:index];
}

@end
