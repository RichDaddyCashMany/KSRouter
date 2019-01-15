//
//  ViewController.m
//  KSRouter
//
//  Created by HJaycee on 2018/10/16.
//  Copyright © 2018年 HJaycee. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 1 直接调用
//    [KSRouter routerToURI:_ModuleA_runDirectly_ args:nil];
    
    // 2 带返回值的调用方式
    __unused id result = [KSRouter routerToURI:_ModuleA_getSomeValue_ args:nil];
    
    // 3 带回调的调用方式
    void(^callback)(BOOL result) = ^(BOOL result){
        
    };
    
    [KSRouter routerToURI:_ModuleA_runWithCallBack_ args:@{@"callback": callback}];
    
    // 4 调用其他组件
    [KSRouter routerToURI:_ModuleA_callOtherModule_ args:nil];
    
    NSError *e = nil;
    [KSRouter performTarget:@"ModuleA" action:@"b" args:nil error:&e];
    e.code == -1; // no module
    e.code == -2; // mo method
    
}


@end
