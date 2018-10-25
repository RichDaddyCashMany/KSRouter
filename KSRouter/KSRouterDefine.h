#import "KSRouter.h"

@KSRouterRegister(ModuleA, runDirectly)
@KSRouterRegister(ModuleA, getSomeValue)
@KSRouterRegister(ModuleA, runWithCallBack)
@KSRouterRegister(ModuleA, callOtherModule)

@KSRouterRegister(ModuleB, run)
