//
//  KSRouter.m
//
//  Created by HJaycee on 2018/9/11.
//  Copyright © 2018年 HJaycee. All rights reserved.
//

#import "KSRouter.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <objc/message.h>
#include <mach-o/getsect.h>
#include <mach-o/loader.h>
#include <mach-o/dyld.h>
#include <dlfcn.h>
#include <mach-o/ldsyms.h>

NSArray<NSString *>* KSReadConfiguration(char *sectionName,const struct mach_header *mhp) {
    NSMutableArray *configs = [NSMutableArray array];
    unsigned long size = 0;
#ifndef __LP64__
    uintptr_t *memory = (uintptr_t*)getsectiondata(mhp, SEG_DATA, sectionName, &size);
#else
    const struct mach_header_64 *mhp64 = (const struct mach_header_64 *)mhp;
    uintptr_t *memory = (uintptr_t*)getsectiondata(mhp64, SEG_DATA, sectionName, &size);
#endif
    
    unsigned long counter = size/sizeof(void*);
    for(int i = 0; i < counter; ++i){
        char *string = (char*)memory[i];
        NSString *str = [NSString stringWithUTF8String:string];
        if(!str)continue;
        
        if(str) [configs addObject:str];
    }
    
    return configs;
}

BOOL is_method_callable(NSString *targetName, NSString *actionName) {
    NSObject *target = [NSClassFromString(targetName) new];
    SEL action = NSSelectorFromString([actionName stringByAppendingString:@":"]);
    if (!target || !action) {
        return NO;
    }
    return [target respondsToSelector:action];
}

static void dyld_callback(const struct mach_header *mhp, intptr_t vmaddr_slide) {
    NSArray<NSString *> *invocations = KSReadConfiguration(KSInvocatations,mhp);
    for (NSString *map in invocations) {
        NSData *jsonData =  [map dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        id json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        if (!error) {
            if ([json isKindOfClass:[NSDictionary class]] && [json allKeys].count) {
                NSString *target = [json allKeys][0];
                NSString *action  = [json allValues][0];
                if (target && action) {
                    if (!is_method_callable(target, action)) {
                        NSLog(@"KSRouter: The following method is not callable: -[%@ %@:]", target, action);
                        #ifdef DEBUG
                        abort();
                        #endif
                    }
                }
            }
        }
    }
}

__attribute__((constructor))
void _init() {
    _dyld_register_func_for_add_image(dyld_callback);
}

@implementation KSRouter

+ (id)routerToURI:(KSRouterURI)URI args:(NSDictionary *)args {
    NSString *uri = [NSString stringWithCString:URI encoding:NSUTF8StringEncoding];
    NSData *jsonData =  [uri dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    id json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    if (!error) {
        if ([json isKindOfClass:[NSDictionary class]] && [json allKeys].count) {
            NSString *target = [json allKeys][0];
            NSString *action  = [json allValues][0];
            if (target && action) {
                return [self performTarget:target action:action args:args];
            }
        }
    }
    return nil;
}

+ (id)performTarget:(NSString *)targetName action:(NSString *)actionName args:(NSDictionary *)args {
    NSObject *target = [NSClassFromString(targetName) new];
    SEL action = NSSelectorFromString([actionName stringByAppendingString:@":"]);
    if (!target || !action) {
        return nil;
    }
    
    if (![target respondsToSelector:action]) {
        return nil;
    }
    
    NSMethodSignature *methodSignature = [target methodSignatureForSelector:action];
    if (!methodSignature) {
        return nil;
    }
    
    const char * returnType = [methodSignature methodReturnType];
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    [invocation setArgument:&args atIndex:2];
    [invocation setSelector:action];
    [invocation setTarget:target];
    [invocation invoke];
    
    id returnValue;
    switch (returnType[0] == _C_CONST ? returnType[1] : returnType[0]) {
#define KSROUTER_RET_OBJECT \
void *value; \
[invocation getReturnValue:&value]; \
id object = (__bridge id)value; \
returnValue = object; \
break;
        case _C_ID: {
            KSROUTER_RET_OBJECT
        }
            
#define KSROUTER_RET_CASE(typeString, type) \
case typeString: {                      \
type value;                         \
[invocation getReturnValue:&value];  \
returnValue = @(value); \
break; \
}
            KSROUTER_RET_CASE(_C_CHR, char)
            KSROUTER_RET_CASE(_C_UCHR, unsigned char)
            KSROUTER_RET_CASE(_C_SHT, short)
            KSROUTER_RET_CASE(_C_USHT, unsigned short)
            KSROUTER_RET_CASE(_C_INT, int)
            KSROUTER_RET_CASE(_C_UINT, unsigned int)
            KSROUTER_RET_CASE(_C_LNG, long)
            KSROUTER_RET_CASE(_C_ULNG, unsigned long)
            KSROUTER_RET_CASE(_C_LNG_LNG, long long)
            KSROUTER_RET_CASE(_C_ULNG_LNG, unsigned long long)
            KSROUTER_RET_CASE(_C_FLT, float)
            KSROUTER_RET_CASE(_C_DBL, double)
            KSROUTER_RET_CASE(_C_BOOL, BOOL)
            
        case _C_STRUCT_B: {
            NSString *typeString = [NSString stringWithUTF8String:returnType];
            
#define KSROUTER_RET_STRUCT(_type, _methodName)                             \
if ([typeString rangeOfString:@#_type].location != NSNotFound) {   \
_type value;                                                   \
[invocation getReturnValue:&value];                            \
returnValue = [NSValue _methodName:value]; \
break;                                                         \
}
            KSROUTER_RET_STRUCT(CGRect, valueWithCGRect)
            KSROUTER_RET_STRUCT(CGPoint, valueWithCGPoint)
            KSROUTER_RET_STRUCT(CGSize, valueWithCGSize)
            KSROUTER_RET_STRUCT(NSRange, valueWithRange)
            KSROUTER_RET_STRUCT(CGVector, valueWithCGVector)
            KSROUTER_RET_STRUCT(UIOffset, valueWithUIOffset)
            KSROUTER_RET_STRUCT(CATransform3D, valueWithCATransform3D)
            KSROUTER_RET_STRUCT(UIEdgeInsets, valueWithUIEdgeInsets)
            KSROUTER_RET_STRUCT(CGAffineTransform, valueWithCGAffineTransform)
        }
        case _C_CHARPTR:
        case _C_PTR:
        case _C_CLASS:{
            KSROUTER_RET_OBJECT
        }
        case _C_VOID:
        default:{
            returnValue = nil;
        }
    }
    
    return returnValue;
}

@end
