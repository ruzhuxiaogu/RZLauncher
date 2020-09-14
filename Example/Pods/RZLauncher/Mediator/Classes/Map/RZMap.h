//
//  RZMap.h
//  Mediator
//
//  Created by tingdongli on 2020/8/19.
//

#import <Foundation/Foundation.h>
#import "RZMapNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface RZMap : NSObject
@property(nonatomic, strong) NSArray<RZMapNode *> *nodes;

- (RZMapNode *)findMapNodeByValue:(NSString *)valueStr;
- (BOOL)detectCircle;

@end

NS_ASSUME_NONNULL_END
