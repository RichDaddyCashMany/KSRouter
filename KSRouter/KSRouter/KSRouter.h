//
//  KSRouter.h
//
//  Created by HJaycee on 2018/9/11.
//  Copyright © 2018年 HJaycee. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef char * KSRouterURI;

#define KSInvocatations "KSInvocatations"

#define KSDATA(sectname) __attribute((used, section("__DATA,"#sectname" ")))

#define KSRouterRegister(target,method) \
class KSMediator; static char *_##target##_##method##_ KSDATA(KSRouter) = "{\""#target"\":\""#method"\"}";

@interface KSRouter : NSObject

+ (id)routerToURI:(KSRouterURI)URI args:(NSDictionary *)args;

@end
