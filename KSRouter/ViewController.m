//
//  ViewController.m
//  KSRouter
//
//  Created by HJaycee on 2018/10/16.
//  Copyright © 2018年 HJaycee. All rights reserved.
//

#import "ViewController.h"
#import "KSRouterDefine.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [KSRouter routerToURI:_ModuleA_doSomeThing_ args:nil];
}


@end
