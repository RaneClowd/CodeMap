//
//  CMValueView.m
//  CodeMap
//
//  Created by Kenny Skaggs on 2/5/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import "CMValueView.h"

#define kDotDiameter 14
#define kDotRadius 7

@interface CMValueView ()

@property (nonatomic, strong) NSTextView* textView;
@property (nonatomic) NSRect dotRect;

@end

@implementation CMValueView

- (id)initWithFrame:(NSRect)frame andNode:(CMNode*)node
{
    self = [super initWithFrame:frame];
    
    NSString* nodeDesc = [node myDescription];
    NSFont* font = [NSFont systemFontOfSize:12];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    NSSize size = [nodeDesc sizeWithAttributes:attributes];
    size.width += 50;
    
    self.textView = [[NSTextView alloc] initWithFrame:CGRectMake(0, 0, size.width, frame.size.height)];
    [self.textView setEditable:NO];
    [self.textView setDrawsBackground:NO];
    [self.textView setFont:font];
    [self.textView setSelectable:NO];
    [self.textView setString:nodeDesc];
    [self addSubview:self.textView];
    
    return self;
}

- (CGFloat)widthNeeded
{
    return self.textView.frame.size.width;
}

- (void)setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
    
    CGFloat heightPadding = self.frame.size.height/2 - kDotRadius;
    self.dotRect = NSMakeRect(self.frame.size.width - kDotDiameter - heightPadding, heightPadding, kDotDiameter, kDotDiameter);
}

- (NSPoint)connectorPoint
{
    return NSMakePoint([self relativeX]+self.dotRect.origin.x+kDotRadius, [self relativeY]+self.dotRect.origin.y+kDotRadius);
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    [[NSColor colorWithCalibratedRed:0.3503 green:0.4323 blue:0.8073 alpha:1] set];
    NSRectFill(NSInsetRect([self bounds], 1, 1));
    
    [[NSColor blackColor] set];
    NSBezierPath* circle = [NSBezierPath bezierPathWithOvalInRect:self.dotRect];
    [circle fill];
}

- (BOOL)isOpaque
{
    return NO;
}

- (BOOL)isDraggable
{
    return NO;
}

@end
