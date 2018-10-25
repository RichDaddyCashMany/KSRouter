#import "KSRouter.h"

@KSRouterRegister(ModuleA, runDirectly)
@KSRouterRegister(ModuleA, getSomeValue)
@KSRouterRegister(ModuleA, runWithCallBack)
@KSRouterRegister(ModuleA, callOtherModule)

@KSRouterRegister(ModuleB, run)

// 假如注册一个不存在的组件方法，在程序启动时就会中断
//@KSRouterRegister(ModuleB, fire)
