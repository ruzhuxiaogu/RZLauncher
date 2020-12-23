//
//  RZModuleRegister.m
//
//  Created by tingdongli on 2019/8/1.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import "RZModuleRegister.h"
#import "RZModuleMediator.h"
#import "RZLauncher.h"
#include <dlfcn.h>
#include <mach-o/dyld.h>
#include <mach-o/getsect.h>
#include <mach-o/ldsyms.h>
#include <mach-o/loader.h>
#import <objc/message.h>
#import <objc/runtime.h>

NSArray<NSString*>* RZReadConfiguration(char* sectionName, const struct mach_header* mhp);

static void dyld_callback(const struct mach_header* mhp, intptr_t vmaddr_slide)
{
    NSArray<NSString*>* protocol2Impls = RZReadConfiguration("RZModuleImpl", mhp);
    for (NSString* protocol2ImplConfig in protocol2Impls) {

        NSArray* array = [protocol2ImplConfig componentsSeparatedByString:@":"];

        if (array.count == 2) {
            NSString* protocol = array[0];
            NSString* clsName = array[1];

            if (protocol && clsName) {
                [[RZModuleMediator sharedInstance] registerProtocol:NSProtocolFromString(protocol) forClass:NSClassFromString(clsName)];
            }
        }
    }
}

NSArray<NSString*>* RZReadConfiguration(char* sectionName, const struct mach_header* mhp)
{
    NSMutableArray* configs = [NSMutableArray array];
    unsigned long size = 0;
#ifndef __LP64__
    uintptr_t* memory = (uintptr_t*)getsectiondata(mhp, SEG_DATA, sectionName, &size);
#else
    const struct mach_header_64* mhp64 = (const struct mach_header_64*)mhp;
    uintptr_t* memory = (uintptr_t*)getsectiondata(mhp64, SEG_DATA, sectionName, &size);
#endif

    unsigned long counter = size / sizeof(void*);
    for (int idx = 0; idx < counter; ++idx) {
        char* string = (char*)memory[idx];
        NSString* str = [NSString stringWithUTF8String:string];
        if (!str)
            continue;

        if (str)
            [configs addObject:str];
    }

    return configs;
}

RZLAUNCH_REGISTER(RZModuleRegister)

@interface RZModuleRegister ()

@end

@implementation RZModuleRegister

- (BOOL)runForLaunchLife:(NSInteger)life
{
    if (life == RZLaunchLife_Constructor) {
        _dyld_register_func_for_add_image(dyld_callback);
        return NO;
    }

    return YES;
}


- (BOOL)runImmediatelyForLaunchLife:(NSInteger)life{
    if (life == RZLaunchLife_Constructor) {
        return YES;
    }
    return NO;
}

@end
