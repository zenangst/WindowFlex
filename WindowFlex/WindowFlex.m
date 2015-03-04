//
//  WindowFlex.m
//  WindowFlex
//
//  Created by Christoffer Winterkvist on 31/10/14.
//    Copyright (c) 2014 zenangst. All rights reserved.
//

#import "WindowFlex.h"
#import "NSObject+ZENSwizzle.h"

CGFloat ZENToolbarMinSize = 300.0f;
CGFloat ZENToolbarMaxSize = 2000.0f;
CGFloat ZENToolbarDefaultMinSize = 320.0f;
CGFloat ZENWindowSizeMinimumWidth = 608.0f;
CGFloat ZENWindowSizeBreakPoint = 650.0f;

static WindowFlex *sharedPlugin;

@interface DVTControllerContentView : NSView
@property (nonatomic) NSView *contentView;
@end

@interface DVTBorderedView : NSView
@property (nonatomic) NSView *contentView;
@end

@interface IDEControlGroup : DVTBorderedView
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

- (BOOL)showsBaselineSeparator
{
    NSArray *itemsToDelete = @[@"Xcode.IDEKit.CustomToolbarItem.Run",
                               @"Xcode.IDEKit.CustomToolbarItem.MultiStop",
                               @"Xcode.IDEKit.CustomToolbarItem.EditorMode",
                               @"Xcode.IDEKit.CustomToolbarItem.Views"
                               ];

    __block BOOL removedItems = NO;
    [self.items enumerateObjectsUsingBlock:^(NSToolbarItem *toolbarItem, NSUInteger idx, BOOL *stop) {
        if ([itemsToDelete containsObject:toolbarItem.itemIdentifier]) {
            [self removeItemAtIndex:idx];
            removedItems = YES;
            *stop = YES;
        }
    }];

    if (removedItems && self.items.count == 3) {
        [self insertItemWithItemIdentifier:NSToolbarFlexibleSpaceItemIdentifier atIndex:0];
    }

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
        NSView *view = self.view;
        view.autoresizingMask = kCALayerWidthSizable;
        view.autoresizesSubviews = YES;
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
        [IDEWorkspaceWindowControllerClass zen_swizzleInstanceSelector:@selector(windowWillResize:toSize:)
                                                          withSelector:@selector(zen_windowWillResize:toSize:)];

        [NSToolbarItem zen_swizzleInstanceSelector:@selector(minSize)
                                      withSelector:@selector(zen_minSize)];
//        [NSToolbarItem zen_swizzleInstanceSelector:@selector(maxSize)
//                                      withSelector:@selector(zen_maxSize)];
    });
}

@end
