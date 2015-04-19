//
//  WindowFlex.m
//  WindowFlex
//
//  Created by Christoffer Winterkvist on 31/10/14.
//    Copyright (c) 2014 zenangst. All rights reserved.
//

#import "WindowFlex.h"

static WindowFlex *sharedPlugin;

@interface WindowFlex()

@property (nonatomic, strong, readwrite) NSBundle *bundle;

@end

@implementation WindowFlex

+ (void)pluginDidLoad:(NSBundle *)plugin {
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if (![currentApplicationName isEqual:@"Xcode"]) return;

    dispatch_once(&onceToken, ^{
        sharedPlugin = [[self alloc] initWithBundle:plugin];
    });
}

+ (instancetype)sharedPlugin {
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)plugin {
    self = [super init];
    if (!self) return nil;

    self.bundle = plugin;

    return self;
}

@end
