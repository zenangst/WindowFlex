//
//  NSObject+ZENSwizzle.h
//  WindowFlex
//
//  Created by Christoffer Winterkvist on 11/8/14.
//  Copyright (c) 2014 zenangst. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/objc-runtime.h>

@interface NSObject (ZENSwizzle)

+ (void)zen_swizzleClassMethod:(NSString *)target withSelector:(NSString *)replacement;
+ (void)zen_swizzleClassMethod:(NSString *)target withSelector:(NSString *)replacement onClass:(Class)class;
+ (void)zen_swizzleInstanceMethod:(NSString *)target withSelector:(NSString *)replacement;
+ (void)zen_swizzleInstanceMethod:(NSString *)target withSelector:(NSString *)replacement onClass:(Class)class;

@end
