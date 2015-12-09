//
//  NSWindow+WindowFlex.m
//  WindowFlex
//
//  Created by Christoffer Winterkvist on 11/17/15.
//  Copyright © 2015 zenangst. All rights reserved.
//

#import "NSWindow+WindowFlex.h"
#import <objc/objc-runtime.h>

@implementation NSWindow (WindowFlex)

+ (void)load {
    Method original, swizzle;

    original = class_getInstanceMethod(self, NSSelectorFromString(@"setMinSize:"));
    swizzle = class_getInstanceMethod(self, NSSelectorFromString(@"zen_setMinSize:"));
    method_exchangeImplementations(original, swizzle);

    original = class_getInstanceMethod(self, NSSelectorFromString(@"setFrame:display:animate:"));
    swizzle = class_getInstanceMethod(self, NSSelectorFromString(@"zen_setFrame:display:animate:"));
    method_exchangeImplementations(original, swizzle);
}

- (void)zen_setMinSize:(NSSize)minSize
{
    NSSize min = { 630, 480 };
    [self zen_setMinSize:min];
}

- (void)zen_setFrame:(NSRect)frameRect display:(BOOL)flag animate:(BOOL)animateFlag {
    if (self.frame.size.width == frameRect.size.width && self.frame.size.width != 960) {
        [self zen_setFrame:frameRect display:flag animate:animateFlag];
    }
}

- (NSWindowTitleVisibility)titleVisibility {
    return NSWindowTitleHidden;
}

@end
