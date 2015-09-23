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
    return YES;
}

- (BOOL)showsBaselineSeparator {

    NSWindow *mainWindow = [[NSApplication sharedApplication] mainWindow];

    if (mainWindow && [[NSUserDefaults standardUserDefaults] boolForKey:kWindowFlexType]) {

        NSArray *itemsToDelete;
        NSArray *itemsToAdd;


        if (mainWindow.frame.size.width <  680) {
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
        } else if (mainWindow.frame.size.width <  880) {
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
        } else if (mainWindow.frame.size.width >  1000) {
            itemsToDelete = @[@""];
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
            NSMutableDictionary *toolbarItems = [self.configurationDictionary mutableCopy];
            toolbarItems[@"TB Item Identifiers"] = itemsToAdd;
            [self setConfigurationFromDictionary:[toolbarItems copy]];
        }
    }
    
    return YES;
}

@end
