//
//  RZMap.h
//  Mediator
//
//  Created by tingdongli on 2020/8/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RZMapNode : NSObject
@property(nonatomic, strong) NSMutableArray<NSString *> *predecessors;
@property(nonatomic, strong) NSMutableArray<NSString *> *successors;
@property(nonatomic, strong) NSString *valueStr;
@end

NS_ASSUME_NONNULL_END
