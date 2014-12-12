//
//  CMNodeView.m
//  CodeMap
//
//  Created by Kenny Skaggs on 1/30/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import "CMNodeView.h"
#import "CMMapDisplayView.h"

@implementation CMNodeView

- (id)init
{
    self = [super init];
    [self initialize];
    return self;
}

- (id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    [self initialize];
    return self;
}

- (void)initialize
{
    self.listenerCollection = [[NSMutableArray alloc] init];
    self.subTargeting = [[NSMutableArray alloc] init];
}

- (void)setTarget:(CMNodeView *)target
{
    _target = target;
    [target.listenerCollection addObject:self];
}

- (NSPoint)connectorPointIsTheTarget:(BOOL)isTarget
{
    return NSMakePoint(self.frame.origin.x + self.frame.size.width/2, self.frame.origin.y + self.frame.size.height/2);
}

- (CGFloat)relativeX
{
    return [self xRelativeToView:self];
}

- (CGFloat)xRelativeToView:(NSView*)view
{
    if ([view class] == [CMMapDisplayView class]) return 0;
    
    return view.frame.origin.x + [self xRelativeToView:[view superview]];
}

- (CGFloat)relativeY
{
    return [self yRelativeToView:self];
}

- (CGFloat)yRelativeToView:(NSView*)view
{
    if ([view class] == [CMMapDisplayView class]) return 0;
    
    return view.frame.origin.y + [self yRelativeToView:[view superview]];
}

- (BOOL)isOpaque
{
    return YES;
}

+ (NSSize)approximateSizeNeededForText:(NSString*)text atFont:(NSFont*)font
{
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    return [text sizeWithAttributes:attributes];
}

@end
