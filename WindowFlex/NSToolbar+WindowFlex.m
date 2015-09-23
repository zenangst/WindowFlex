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

    if ([[NSUserDefaults standardUserDefaults] boolForKey:kWindowFlexType]) {

    NSArray *itemsToDelete = @[@"Xcode.IDEKit.CustomToolbarItem.Run",
                               @"Xcode.IDEKit.CustomToolbarItem.MultiStop",
                               @"Xcode.IDEKit.CustomToolbarItem.Views"
                               ];

    __block BOOL shouldConfigureToolbar = NO;
    [self.items enumerateObjectsUsingBlock:^(NSToolbarItem *toolbarItem, NSUInteger idx, BOOL *stop) {
        if ([itemsToDelete containsObject:toolbarItem.itemIdentifier]) {
            shouldConfigureToolbar = YES;
            *stop = YES;
        }
    }];

      if (shouldConfigureToolbar == true || self.items.count == 0) {
        NSMutableDictionary *mdict = [self.configurationDictionary mutableCopy];
        mdict[@"TB Item Identifiers"] = @[@"NSToolbarFlexibleSpaceItem",
                                          @"Xcode.IDEKit.CustomToolbarItem.ActiveScheme",
                                          @"Xcode.IDEKit.CustomToolbarItem.Activity",
                                          @"Xcode.IDEKit.CustomToolbarItem.EditorMode",
                                          @"NSToolbarFlexibleSpaceItem"
                                          ];
        [self setConfigurationFromDictionary:[mdict copy]];
      }

    }

  return YES;
}

@end
