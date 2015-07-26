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
                               @"Xcode.IDEKit.CustomToolbarItem.EditorMode",
                               @"Xcode.IDEKit.CustomToolbarItem.ActiveScheme",
                               @"Xcode.IDEKit.CustomToolbarItem.Views"];

    __block BOOL removedItems = NO;
    [self.items enumerateObjectsUsingBlock:^(NSToolbarItem *toolbarItem, NSUInteger idx, BOOL *stop) {
        if ([itemsToDelete containsObject:toolbarItem.itemIdentifier]) {
            [self removeItemAtIndex:idx];
            removedItems = YES;
            *stop = YES;
        }
    }];

    if (removedItems && self.items.count == 2) {
        [self insertItemWithItemIdentifier:NSToolbarFlexibleSpaceItemIdentifier
                                   atIndex:0];
    }

    }

    NSURL *receiptURL =[[NSBundle mainBundle].bundleURL URLByAppendingPathComponent:@"Contents/_MASReceipt/receipt"];
    BOOL isAppStore = [receiptURL checkResourceIsReachableAndReturnError:nil];
    if (isAppStore) {
        return NO;
    } else {
        return YES;
    }
}

@end
