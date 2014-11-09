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

+ (void)zen_swizzleClassSelector:(SEL)originalSelector withSelector:(SEL)swizzledSelector;
+ (void)zen_swizzleInstanceSelector:(SEL)originalSelector withSelector:(SEL)swizzledSelector;

@end
