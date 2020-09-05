//
//  RZModuleMediator.h
//
//  Created by tingdongli on 2019/7/24.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RZModuleBaseProtocol.h"
#import "RZModuleRegister.h"

NS_ASSUME_NONNULL_BEGIN

@interface RZModuleMediator : NSObject

+ (instancetype)sharedInstance;

//注册类
- (void)registerProtocol:(Protocol*)protocol forClass:(Class)cls;
- (Class)classForProtocol:(Protocol*)protocol;

//接口的实现类
- (id)implForProtocol:(Protocol*)protocol;

+ (id)implObjForProtocol:(Protocol*)protocol;

@end

NS_ASSUME_NONNULL_END
