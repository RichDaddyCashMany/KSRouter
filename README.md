# KSRouter
支持自动注册的的iOS组件化解决方案


## 比如组件内部实现了这样的功能

```
@implementation ModuleA

- (id)doSomeThing:(NSDictionary *)arg {
    return nil;
}
```

## 1. 注册组件

```
@KSRouterRegister(ModuleA, doSomeThing)
```

## 2. 调用组件

```
[KSRouter routerToURI:_ModuleA_doSomeThing_ args:nil];
```



