//
//  CMAppDelegate.m
//  CodeMap
//
//  Created by Kenny Skaggs on 1/25/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import "CMAppDelegate.h"

#import "CMMapViewController.h"

@interface CMAppDelegate ()

@property (nonatomic,strong) NSViewController* mapViewController;

@end

@implementation CMAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.mapViewController = [[CMMapViewController alloc] initWithNibName:@"CMMapViewController" bundle:nil];
    
    [self.window.contentView addSubview:self.mapViewController.view];
    self.mapViewController.view.frame = ((NSView*)self.window.contentView).bounds;
}

@end
