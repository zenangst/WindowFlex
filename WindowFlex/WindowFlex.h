//
//  WindowFlex.h
//  WindowFlex
//
//  Created by Christoffer Winterkvist on 31/10/14.
//  Copyright (c) 2014 zenangst. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface WindowFlex : NSObject

+ (instancetype)sharedPlugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;
@end