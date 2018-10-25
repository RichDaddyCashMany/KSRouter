# KSRouter
> 支持自动注册的的iOS组件化解决方案，用于多端复用等场景。

* 自动注册式的安全检查
* 宏注册并生成常量路由
* 支持任意的返回值类型
* 支持回调形式的调用方式
* 可组件间调用
* 支持子仓库组件间调用

---


## 简单例子

> 假设`ModuleA `组件内部实现了`run`功能


#### 1. 注册组件

```
@KSRouterRegister(ModuleA, run)
```

#### 2. 调用组件

```
// "_ModuleA_run_"路由由编译器自动生成，支持代码提示

[KSRouter routerToURI:_ModuleA_run_ args:nil];
```

## 更多例子

> `PrefixHeader.pch`文件中引入`#import "KSRouterDefine.h"`

KSRouterDefine.h

```
#import "KSRouter.h"

@KSRouterRegister(ModuleA, runDirectly)
@KSRouterRegister(ModuleA, getSomeValue)
@KSRouterRegister(ModuleA, runWithCallBack)
@KSRouterRegister(ModuleA, callOtherModule)

@KSRouterRegister(ModuleB, run)
```

ViewController.m

```
// 1 直接调用
[KSRouter routerToURI:_ModuleA_runDirectly_ args:nil];

// 2 带返回值的调用方式
__unused id result = [KSRouter routerToURI:_ModuleA_getSomeValue_ args:nil];

// 3 带回调的调用方式
void(^callback)(BOOL result) = ^(BOOL result){
    
};

[KSRouter routerToURI:_ModuleA_runWithCallBack_ args:@{@"callback": callback}];

// 4 调用其他组件
[KSRouter routerToURI:_ModuleA_callOtherModule_ args:nil];
```

ModuleA.m

```
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
```

ModuleB.m

```
- (void)run:(NSDictionary *)arg {
}
```