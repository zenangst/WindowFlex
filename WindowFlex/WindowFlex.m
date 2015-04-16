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
        [self insertItemWithItemIdentifier:NSToolbarFlexibleSpaceItemIdentifier
                                   atIndex:0];
    }

    return NO;
}

@end

@implementation NSView (ZEN)

- (void)zen_drawRect:(NSRect)dirtyRect
{
    if ([self isKindOfClass:NSClassFromString(@"DVTFindBarControllerContentView")]) {
//        [[NSColor colorWithSRGBRed:0.847f
//                             green:0.847f
//                              blue:0.847f
//                             alpha:1.0f] setFill];
//        NSRectFill(dirtyRect);
    }

    [self zen_drawRect:dirtyRect];
}

- (void)zen_setFrame:(NSRect)frame
{
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
            [borderedView zen_setFrame:newFrame];

            frame.origin.y -= frame.size.height - 1;
        }
    }

    if ([self isKindOfClass:NSClassFromString(@"DVTBorderedView")]) {}
    if ([self isKindOfClass:NSClassFromString(@"DVTSplitView")]) {}

    [self zen_setFrame:frame];
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

        [NSView zen_swizzleInstanceSelector:@selector(setFrame:)
                               withSelector:@selector(zen_setFrame:)];
        [NSView zen_swizzleInstanceSelector:@selector(drawRect:)
                               withSelector:@selector(zen_drawRect:)];
    });
}

@end
