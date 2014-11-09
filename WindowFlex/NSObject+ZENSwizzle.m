//
//  NSObject+ZENSwizzle.m
//  WindowFlex
//
//  Created by Christoffer Winterkvist on 11/8/14.
//  Copyright (c) 2014 zenangst. All rights reserved.
//

#import "NSObject+ZENSwizzle.h"

@interface NSString (ZENSwizzle)
+ (void)_swizzleMethod:(Method)originalMethod withSelector:(SEL)originalSelector withMethod:(Method)swizzledMethod withSelector:(SEL)swizzledSelector;
@end

@implementation NSObject (ZENSwizzle)

+ (void)zen_swizzleClassMethod:(NSString *)target withSelector:(NSString *)replacement
{
    SEL originalSelector = NSSelectorFromString(target);
    SEL swizzledSelector = NSSelectorFromString(replacement);

    Method originalMethod = class_getClassMethod(self.class, originalSelector);
    Method swizzledMethod = class_getClassMethod(self.class, swizzledSelector);

    [self zen_swizzleMethod:originalMethod withSelector:originalSelector withMethod:swizzledMethod withSelector:swizzledSelector];
}

+ (void)zen_swizzleInstanceMethod:(NSString *)target withSelector:(NSString *)replacement
{
    SEL originalSelector = NSSelectorFromString(target);
    SEL swizzledSelector = NSSelectorFromString(replacement);
    Method originalMethod = class_getInstanceMethod(self.class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(self.class, swizzledSelector);

    [self zen_swizzleMethod:originalMethod withSelector:originalSelector withMethod:swizzledMethod withSelector:swizzledSelector];
}

+ (void)zen_swizzleMethod:(Method)originalMethod
             withSelector:(SEL)originalSelector
               withMethod:(Method)swizzledMethod
             withSelector:(SEL)swizzledSelector
{
    BOOL didAddMethod = class_addMethod(self.class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));

    if (didAddMethod) {
        class_replaceMethod(self.class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@end
