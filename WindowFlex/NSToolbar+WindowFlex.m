//
//  NSToolbar+WindowFlex.m
//  WindowFlex
//
//  Created by Christoffer Winterkvist on 19/04/15.
//  Copyright (c) 2015 zenangst. All rights reserved.
//

#import "NSToolbar+WindowFlex.h"
#import <objc/objc-runtime.h>

static NSString *const kWindowFlexType = @"WindowFlexTypeWindowFlexType";

@implementation NSToolbar (WindowFlex)

- (BOOL)allowsUserCustomization {
    return YES;
}

- (BOOL)autosavesConfiguration {
    return NO;
}

- (BOOL)visible {
    return YES;
}

- (void)setVisible:(BOOL)visible
{
    visible = true;
}

- (BOOL)showsBaselineSeparator {
    if (![self.identifier hasPrefix:@"Xcode.IDEKit.ToolbarDefinition"]) {
      return YES;
    }
    
    if (self.visible) {
        [self setVisible:NO];
    }

    NSWindow *mainWindow = [[NSApplication sharedApplication] mainWindow];

    if (mainWindow &&
        [mainWindow isKindOfClass:NSClassFromString(@"IDEWorkspaceWindow")] &&
        [[NSUserDefaults standardUserDefaults] boolForKey:kWindowFlexType]) {

        NSArray *itemsToDelete;
        NSArray *itemsToAdd;

        NSMutableDictionary *toolbarItems = [self.configurationDictionary mutableCopy];

        if ([[self.configurationDictionary[@"TB Default Item Identifiers"] mutableCopy] count] == 0) {
            itemsToDelete = @[
                              @"Xcode.IDEKit.CustomToolbarItem.ActiveScheme",
                              @"Xcode.IDEKit.CustomToolbarItem.Run",
                              @"Xcode.IDEKit.CustomToolbarItem.MultiStop",
                              @"Xcode.IDEKit.CustomToolbarItem.EditorMode",
                              @"Xcode.IDEKit.CustomToolbarItem.Views",
                              ];

            itemsToAdd = @[];

            __block BOOL shouldConfigureToolbar = NO;
            [self.items enumerateObjectsUsingBlock:^(NSToolbarItem *toolbarItem, NSUInteger idx, BOOL *stop) {
                if ([itemsToDelete containsObject:toolbarItem.itemIdentifier]) {
                    shouldConfigureToolbar = YES;
                    *stop = YES;
                }
            }];

            if (shouldConfigureToolbar == true || self.items.count != itemsToAdd.count) {
                toolbarItems[@"TB Item Identifiers"] = itemsToAdd;
                [self setConfigurationFromDictionary:[toolbarItems copy]];
            }
        } else if ([[self.configurationDictionary[@"TB Default Item Identifiers"] mutableCopy] count] > 6) {
            if (self.configurationDictionary[@"TB Item Identifiers"]) {

                if (mainWindow.frame.size.width <  820) {
                    itemsToDelete = @[
                                      @"Xcode.IDEKit.CustomToolbarItem.ActiveScheme",
                                      @"Xcode.IDEKit.CustomToolbarItem.Run",
                                      @"Xcode.IDEKit.CustomToolbarItem.MultiStop",
                                      @"Xcode.IDEKit.CustomToolbarItem.EditorMode",
                                      @"Xcode.IDEKit.CustomToolbarItem.Views",
                                      ];

                    itemsToAdd = @[
                                   @"NSToolbarFlexibleSpaceItem",
                                   @"Xcode.IDEKit.CustomToolbarItem.Activity",
                                   @"NSToolbarFlexibleSpaceItem",
                                   ];
                } else if (mainWindow.frame.size.width <  900) {
                    itemsToDelete = @[
                                      @"Xcode.IDEKit.CustomToolbarItem.Run",
                                      @"Xcode.IDEKit.CustomToolbarItem.MultiStop",
                                      @"Xcode.IDEKit.CustomToolbarItem.EditorMode",
                                      @"Xcode.IDEKit.CustomToolbarItem.Views",
                                      ];

                    itemsToAdd = @[
                                   @"NSToolbarFlexibleSpaceItem",
                                   @"Xcode.IDEKit.CustomToolbarItem.ActiveScheme",
                                   @"Xcode.IDEKit.CustomToolbarItem.Activity",
                                   @"NSToolbarFlexibleSpaceItem",
                                   ];
                } else if (mainWindow.frame.size.width <  950) {
                    itemsToDelete = @[
                                      @"Xcode.IDEKit.CustomToolbarItem.Run",
                                      @"Xcode.IDEKit.CustomToolbarItem.MultiStop",
                                      @"Xcode.IDEKit.CustomToolbarItem.Views"
                                      ];

                    itemsToAdd = @[
                                   @"NSToolbarFlexibleSpaceItem",
                                   @"Xcode.IDEKit.CustomToolbarItem.ActiveScheme",
                                   @"Xcode.IDEKit.CustomToolbarItem.Activity",
                                   @"NSToolbarFlexibleSpaceItem",
                                   @"Xcode.IDEKit.CustomToolbarItem.EditorMode"
                                   ];
                } else if (mainWindow.frame.size.width >  1100) {
                    itemsToDelete = @[];
                    itemsToAdd = @[
                                   @"Xcode.IDEKit.CustomToolbarItem.Run",
                                   @"Xcode.IDEKit.CustomToolbarItem.MultiStop",
                                   @"NSToolbarFlexibleSpaceItem",
                                   @"Xcode.IDEKit.CustomToolbarItem.ActiveScheme",
                                   @"Xcode.IDEKit.CustomToolbarItem.Activity",
                                   @"NSToolbarFlexibleSpaceItem",
                                   @"Xcode.IDEKit.CustomToolbarItem.EditorMode",
                                   @"Xcode.IDEKit.CustomToolbarItem.Views",
                                   ];
                } else {
                    itemsToDelete = @[
                                      @"Xcode.IDEKit.CustomToolbarItem.Run",
                                      @"Xcode.IDEKit.CustomToolbarItem.MultiStop"
                                      ];
                    itemsToAdd = @[
                                   @"Xcode.IDEKit.CustomToolbarItem.ActiveScheme",
                                   @"NSToolbarFlexibleSpaceItem",
                                   @"Xcode.IDEKit.CustomToolbarItem.Activity",
                                   @"NSToolbarFlexibleSpaceItem",
                                   @"Xcode.IDEKit.CustomToolbarItem.EditorMode",
                                   @"Xcode.IDEKit.CustomToolbarItem.Views",
                                   ];
                }

                __block BOOL shouldConfigureToolbar = NO;
                [self.items enumerateObjectsUsingBlock:^(NSToolbarItem *toolbarItem, NSUInteger idx, BOOL *stop) {
                    if ([itemsToDelete containsObject:toolbarItem.itemIdentifier]) {
                        shouldConfigureToolbar = YES;
                        *stop = YES;
                    }
                }];

                if (shouldConfigureToolbar == true || self.items.count != itemsToAdd.count) {
                    toolbarItems[@"TB Item Identifiers"] = itemsToAdd;
                    [self setConfigurationFromDictionary:[toolbarItems copy]];
                }
            }
        }
    }

    return NO;
}

@end
