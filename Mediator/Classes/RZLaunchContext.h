//
//  RZLaunchContext.h
//  Mediator
//
//  Created by tingdongli on 2020/3/19.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RZLaunchContext : NSObject

@property (nonatomic, strong) UIApplication* application;
@property (nonatomic, strong) NSDictionary* launchOptions;

@end

NS_ASSUME_NONNULL_END
