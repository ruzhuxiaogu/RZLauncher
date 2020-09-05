//
//  RZLauncher.h
//  Mediator
//
//  Created by tingdongli on 2020/3/19.
//

#import <Foundation/Foundation.h>
#import "RZLaunchProtocol.h"
#import "RZLaunchContext.h"

#define RZL_ADD_SECTION_DATA(sectname) __attribute((used, section("__DATA," #sectname " ")))

#define RZLAUNCH_REGISTER(task) \
    char* k##task##_register RZL_ADD_SECTION_DATA(RZLauncher) = "" #task "";

#define RZLocalLaunchConfigName @"RZLaunchTask"

NS_ASSUME_NONNULL_BEGIN

extern NSArray<NSString*>* RZLaunchLoadConfiguration(const char* sectionName);

@interface RZLauncher : NSObject

@property (nonatomic, strong) RZLaunchContext* context;

+ (instancetype)sharedLauncher;
- (void)onTrigger:(NSInteger)type;
- (NSDictionary *)getLaunchTaskReport;

@end

NS_ASSUME_NONNULL_END

