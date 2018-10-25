//
//  ModuleA.m
//  KSRouter
//
//  Created by HJaycee on 2018/10/16.
//  Copyright © 2018年 HJaycee. All rights reserved.
//

#import "ModuleA.h"

@implementation ModuleA

- (void)runDirectly:(NSDictionary *)arg {
    NSLog(@"直接调用");
}

- (id)getSomeValue:(NSDictionary *)arg {
    NSLog(@"带返回值的调用方式");
    
    return @1;
}

- (void)runWithCallBack:(NSDictionary *)arg {
    NSLog(@"带回调的调用方式");
    
    if (arg[@"callback"]) {
        void(^callback)(BOOL result) = arg[@"callback"];
        callback(YES);
    }
}

- (void)callOtherModule:(NSDictionary *)arg {
    NSLog(@"调用其他组件");
    
    [KSRouter routerToURI:_ModuleB_run_ args:nil];
}

@end
