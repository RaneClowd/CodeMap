//
//  CMContainerView.m
//  CodeMap
//
//  Created by Kenny Skaggs on 2/13/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import "CMContainerView.h"

@interface CMContainerView ()

@end

@implementation CMContainerView

- (id)initWithLocation:(NSPoint)location andTitle:(NSString *)title
{
    NSFont* font = [NSFont systemFontOfSize:20];
    NSSize titleSize = [CMNodeView approximateSizeNeededForText:title atFont:font];
    titleSize.height += 20;
    titleSize.width += 20;
    
    self = [super initWithFrame:CGRectMake(location.x, location.y, titleSize.width, titleSize.height)];
    
    self.titleView = [[NSTextView alloc] initWithFrame:CGRectMake(0, 0, titleSize.width, titleSize.height)];
    
    [self.titleView setFont:font];
    [self.titleView setEditable:NO];
    [self.titleView setSelectable:NO];
    [self.titleView setString:title];
    [self.titleView setDrawsBackground:NO];
    [self.titleView setAlignment:NSRightTextAlignment];
    [self addSubview:self.titleView];
    
    return self;
}

- (void)setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
    
    NSRect frame = self.titleView.frame;
    NSPoint titleLocation = [self locationForTitleViewBasedOn:frame.size];
    frame.origin = titleLocation;
    self.titleView.frame = frame;
}

- (NSPoint)locationForTitleViewBasedOn:(NSSize)size
{
    return NSMakePoint(self.frame.size.width-size.width, self.frame.size.height-size.height);
}

@end
