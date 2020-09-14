//
//  RZModuleRegister.h
//
//  Created by tingdongli on 2019/8/1.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RZAppLaunchBaseTask.h"

#define RZM_ADD_SECTION_DATA(sectname) __attribute((used, section("__DATA," #sectname " ")))

#define RZM_EXPORT_MODULE_PROTOCOL(protocolName, impl) \
    char* k##protocolName##_service RZM_ADD_SECTION_DATA(RZModuleImpl) = "" #protocolName ":" #impl "";

NS_ASSUME_NONNULL_BEGIN

@interface RZModuleRegister : RZAppLaunchBaseTask
@end

NS_ASSUME_NONNULL_END
