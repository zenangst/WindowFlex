//
//  WindowFlex.m
//  WindowFlex
//
//  Created by Christoffer Winterkvist on 31/10/14.
//    Copyright (c) 2014 zenangst. All rights reserved.
//

#import "WindowFlex.h"

static NSString *const kWindowFlexType = @"WindowFlexTypeWindowFlexType";
static WindowFlex *sharedPlugin;

@interface WindowFlex()

@property (nonatomic, readwrite) NSBundle *bundle;
@property (nonatomic) NSMenuItem *flexTypeMenuItem;

@end

@implementation WindowFlex

+ (void)pluginDidLoad:(NSBundle *)plugin {
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if (![currentApplicationName isEqual:@"Xcode"]) return;

    dispatch_once(&onceToken, ^{
        sharedPlugin = [[self alloc] init];
    });
}

+ (instancetype)sharedPlugin {
    return sharedPlugin;
}

- (instancetype)init {
    self = [super init];
    if (!self) return nil;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidFinishLaunching:)
                                                 name:NSApplicationDidFinishLaunchingNotification
                                               object:nil];

    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {

    NSMenuItem *windowMenuItem = [[NSApp mainMenu] itemWithTitle:@"Window"];

    if (windowMenuItem) {
        NSMenu *pluginMenu = [[NSMenu alloc] initWithTitle:@"Window Flex"];
        [[windowMenuItem submenu] addItem:[NSMenuItem separatorItem]];

        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSInteger state = [userDefaults objectForKey:kWindowFlexType] ? [[userDefaults objectForKey:kWindowFlexType] integerValue] : 1;

        _flexTypeMenuItem = [[NSMenuItem alloc] initWithTitle:@"Clean Flex"
                                                       action:@selector(toggleFlex)
                                                keyEquivalent:@""];
        _flexTypeMenuItem.state = state;
        _flexTypeMenuItem.target = self;

        [pluginMenu addItem:_flexTypeMenuItem];

        NSString *versionString = [[NSBundle bundleForClass:[self class]] objectForInfoDictionaryKey:@"CFBundleVersion"];
        NSString *title = [NSString stringWithFormat:@"Window Flex (%@)", versionString];
        NSMenuItem *pluginMenuItem = [[NSMenuItem alloc] initWithTitle:title
                                                                action:nil
                                                         keyEquivalent:@""];
        pluginMenuItem.submenu = pluginMenu;

        [[windowMenuItem submenu] addItem:pluginMenuItem];
    }
}


- (void)toggleFlex {
    self.flexTypeMenuItem.state = (self.flexTypeMenuItem.state == 1) ? 0 : 1;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@(self.flexTypeMenuItem.state) forKey:kWindowFlexType];
    [userDefaults synchronize];
}

@end
