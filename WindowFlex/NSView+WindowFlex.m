//
//  NSView+WindowFlex.m
//  WindowFlex
//
//  Created by Christoffer Winterkvist on 19/04/15.
//  Copyright (c) 2015 zenangst. All rights reserved.
//

#import "NSView+WindowFlex.h"
#import <objc/objc-runtime.h>

@interface DVTControllerContentView : NSView
    @property (nonatomic) NSView *contentView;
@end

@interface DVTBorderedView : NSView
    @property (nonatomic) NSView *contentView;
@end

@implementation NSView (WindowFlex)

+ (void)load {
    Method original, swizzle;

    original = class_getInstanceMethod(self, NSSelectorFromString(@"setFrame:"));
    swizzle = class_getInstanceMethod(self, NSSelectorFromString(@"zen_setFrame:"));

    method_exchangeImplementations(original, swizzle);
}

- (void)zen_setFrame:(NSRect)frame {
    if ([self isKindOfClass:NSClassFromString(@"IDENavBar")]) {
        NSView *containerView = self.superview;
        DVTBorderedView *borderedView;

        for (id view in containerView.subviews) {
            if ([view isKindOfClass:NSClassFromString(@"DVTBorderedView")]) {
                borderedView = view;
                break;
            }
        }

        BOOL shouldResize = (([containerView.subviews count] < 4) &&
                             (containerView.frame.size.height >= borderedView.frame.size.height));
        if (shouldResize) {
            [containerView addSubview:borderedView];
            NSRect newFrame = containerView.frame;
            [borderedView setFrame:newFrame];
            frame.origin.y = containerView.frame.size.height - frame.size.height * 2;
        }
    }

    [self zen_setFrame:frame];
}

@end
