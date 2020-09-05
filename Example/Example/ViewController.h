//
//  ViewController.h
//  Example
//
//  Created by 李鹏 on 2020/1/3.
//  Copyright © 2020 pennyli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RZModuleMediator.h"

@protocol TestProtocol <RZModuleBaseProtocol>

- (void)test;

@end

@interface TestImpl : NSObject <TestProtocol>

@end


RZM_EXPORT_MODULE_PROTOCOL(TestProtocol, TestImpl)

@interface ViewController : UIViewController


@end

