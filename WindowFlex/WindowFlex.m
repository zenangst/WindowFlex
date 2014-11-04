//
//  WindowFlex.m
//  WindowFlex
//
//  Created by Christoffer Winterkvist on 31/10/14.
//    Copyright (c) 2014 zenangst. All rights reserved.
//

#import <objc/objc-runtime.h>
#import "WindowFlex.h"

CGFloat ZENToolbarMinSize = 300.0f;
CGFloat ZENToolbarMaxSize = 2000.0f;
CGFloat ZENToolbarDefaultMinSize = 320.0f;
CGFloat ZENWindowSizeMinimumWidth = 608.0f;
CGFloat ZENWindowSizeBreakPoint = 650.0f;

static WindowFlex *sharedPlugin;

@implementation NSView (ZEN)

- (void)zen_setFrame:(NSRect)frame
{
    if ([self isKindOfClass:NSClassFromString(@"IDENavBar")]) {
        NSView *view = self.superview;
        NSView *contentView = [[view subviews] objectAtIndex:1];

        if (view.frame.size.height >= contentView.frame.size.height) {
            NSRect newFrame = contentView.frame;
            newFrame.size.height = view.frame.size.height;
            [contentView zen_setFrame:newFrame];
        }
    }

    [self zen_setFrame:frame];
}

@end

@implementation NSWindowController (ZEN)

- (NSSize)zen_windowWillResize:(NSWindow *)sender
                        toSize:(NSSize)frameSize
{
    if (frameSize.width <= ZENWindowSizeMinimumWidth) {
        frameSize.width = ZENWindowSizeMinimumWidth;
    }

    return frameSize;
}

@end

@implementation NSToolbar (ZEN)

- (BOOL)allowsUserCustomization
{
    return YES;
}

- (BOOL)autosavesConfiguration
{
    return YES;
}

@end

@implementation NSToolbarItem (ZEN)

- (NSSize)zen_minSize
{
    NSSize size = [self zen_minSize];

    Class activityClass = NSClassFromString(@"_IDEActivityViewControllerToolbarItem");

    if ([self isKindOfClass:activityClass]) {
        self.visibilityPriority = NSToolbarItemVisibilityPriorityUser;
        size.width = ZENToolbarDefaultMinSize;
    }

    return size;
}

- (NSSize)zen_maxSize
{
    NSSize size = [self zen_maxSize];

    Class activityClass = NSClassFromString(@"_IDEActivityViewControllerToolbarItem");

    if ([self isKindOfClass:activityClass]) {
        size.width = ZENToolbarMaxSize;
    }

    return size;
}

@end

@interface WindowFlex()

@property (nonatomic, strong, readwrite) NSBundle *bundle;

@end

@implementation WindowFlex

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if (![currentApplicationName isEqual:@"Xcode"]) return;

    dispatch_once(&onceToken, ^{
        sharedPlugin = [[self alloc] initWithBundle:plugin];
    });
}

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)plugin
{
    self = [super init];
    if (!self) return nil;

    self.bundle = plugin;

    [self swizzle];

    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)swizzle
{
    static dispatch_once_t onceToken;

    Class IDEWorkspaceWindowControllerClass = NSClassFromString(@"IDEWorkspaceWindowController");

    dispatch_once(&onceToken, ^{
        [self swizzleClass:IDEWorkspaceWindowControllerClass
          originalSelector:@selector(windowWillResize:toSize:)
          swizzledSelector:@selector(zen_windowWillResize:toSize:)
            instanceMethod:YES];

        [self swizzleClass:[NSToolbarItem class]
          originalSelector:@selector(minSize)
          swizzledSelector:@selector(zen_minSize)
            instanceMethod:YES];

        [self swizzleClass:[NSToolbarItem class]
          originalSelector:@selector(maxSize)
          swizzledSelector:@selector(zen_maxSize)
            instanceMethod:YES];

        [self swizzleClass:[NSView class]
          originalSelector:@selector(setFrame:)
          swizzledSelector:@selector(zen_setFrame:)
            instanceMethod:YES];
    });
}

- (void)swizzleClass:(Class)class originalSelector:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector instanceMethod:(BOOL)instanceMethod
{
    if (class) {
        Method originalMethod;
        Method swizzledMethod;
        if (instanceMethod) {
            originalMethod = class_getInstanceMethod(class, originalSelector);
            swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        } else {
            originalMethod = class_getClassMethod(class, originalSelector);
            swizzledMethod = class_getClassMethod(class, swizzledSelector);
        }

        BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));

        if (didAddMethod) {
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    }
}

@end
