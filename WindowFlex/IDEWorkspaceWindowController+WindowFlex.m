//
//  IDEWorkspaceWindowController+WindowFlex.m
//  WindowFlex
//
//  Created by Christoffer Winterkvist on 19/04/15.
//  Copyright (c) 2015 zenangst. All rights reserved.
//

#import "IDEWorkspaceWindowController+WindowFlex.h"
#import <objc/objc-runtime.h>

CGFloat ZENWindowSizeMinimumWidth = 630.0f;
CGFloat ZENWindowSizeBreakPoint = 650.0f;

@implementation IDEWorkspaceWindowController (WindowFlex)

+ (void)load {
    Method original, swizzle;

    original = class_getInstanceMethod(self, NSSelectorFromString(@"windowWillResize:toSize:"));
    swizzle = class_getInstanceMethod(self, NSSelectorFromString(@"zen_windowWillResize:toSize:"));
    method_exchangeImplementations(original, swizzle);

    original = class_getInstanceMethod(self, NSSelectorFromString(@"windowWillMove:"));
    swizzle = class_getInstanceMethod(self, NSSelectorFromString(@"zen_windowWillMove:"));
    method_exchangeImplementations(original, swizzle);
}

- (NSSize)zen_windowWillResize:(NSWindow *)sender
                        toSize:(NSSize)frameSize {
    if (frameSize.width <= ZENWindowSizeMinimumWidth) {
        frameSize.width = ZENWindowSizeMinimumWidth;
    }

    return frameSize;
}

- (void)zen_windowWillMove:(NSNotification *)notification
{
    [self zen_windowWillMove:notification];
    [self zen_windowWillResize:[self window] toSize:[[self window] frame].size];
}

@end
