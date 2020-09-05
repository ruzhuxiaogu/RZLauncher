//
//  ViewController.m
//  Example
//
//  Created by 李鹏 on 2020/1/3.
//  Copyright © 2020 pennyli. All rights reserved.
//

#import "ViewController.h"

@implementation TestImpl

- (void)test
{
    NSLog(@"123");
}

@end

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[RZModuleMediator implObjForProtocol: @protocol(TestProtocol)] test];
}


@end
