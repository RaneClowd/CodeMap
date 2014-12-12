//
//  CMContainerView.m
//  CodeMap
//
//  Created by Kenny Skaggs on 2/13/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import "CMContainerView.h"
#import "CMConnectorView.h"

#define kDotDiameter 14
#define kDotRadius 7

@interface CMContainerView ()

@end

@implementation CMContainerView

- (id)initWithLocation:(NSPoint)location size:(int)size andTitle:(NSString *)title
{
    NSFont* font = [NSFont systemFontOfSize:size];
    NSSize titleSize = [CMNodeView approximateSizeNeededForText:title atFont:font];
    titleSize.height += size;
    titleSize.width += size;
    
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

- (NSPoint)connectorPointIsTheTarget:(BOOL)isTarget
{
    CMContainerView* containingView = (CMContainerView*)[self superview];
    if (containingView.collapsed) {
        return [containingView connectorPointIsTheTarget:isTarget];
    } else {
        if (isTarget) {
            return NSMakePoint([self relativeX]+self.dotRect.origin.x+kDotRadius, [self relativeY]+self.dotRect.origin.y+kDotRadius);
        } else {
            return NSMakePoint([self relativeX]+self.secondaryDotRect.origin.x+kDotRadius, [self relativeY]+self.secondaryDotRect.origin.y+kDotRadius);
        }
    }
}

- (void)mouseDown:(NSEvent *)theEvent
{
    if ([theEvent clickCount] == 2) {
        [self toggleCollapsed];
        [[CMConnectorView sharedInstance] setNeedsDisplay:YES];
    }
}

- (void)toggleCollapsed
{
    if (self.collapsed) {
        self.frame = (CGRect){self.frame.origin, self.sizeBeforeCollapse};
        [self showSubviews];
        [((id<CMSuperView>)self.superview) expandIfNeededToContainChild:self];
    } else {
        self.sizeBeforeCollapse = self.frame.size;
        self.frame = (CGRect){self.frame.origin, NSMakeSize(self.titleView.frame.size.width+kDotDiameter, self.titleView.frame.size.height)};
        [self hideSubviews];
    }
    self.collapsed = !self.collapsed;
    
    [self setNeedsDisplay:YES];
}

- (void)hideSubviews
{
    for (NSView* subView in [self subviews]) {
        if (subView != self.titleView) [subView setHidden:YES];
    }
}

- (void)showSubviews
{
    for (NSView* subView in [self subviews]) {
        if (subView != self.titleView) [subView setHidden:NO];
    }
}

- (NSView *)hitTest:(NSPoint)aPoint
{
    for (NSView* subView in [self subviews]) {
        if ([[subView class] isSubclassOfClass:[CMContainerView class]]) {
            NSView* hitView = [subView hitTest:[self convertPoint:aPoint fromView:[self superview]]];
            if (hitView) return hitView;
        }
    }
    
    if (![self isHidden] && NSPointInRect(aPoint, self.frame)) return self;
    else return nil;
}

- (void)setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
    
    NSRect frame = self.titleView.frame;
    NSPoint titleLocation = [self locationForTitleViewBasedOn:frame.size];
    frame.origin = titleLocation;
    self.titleView.frame = frame;
    
    self.dotRect = NSMakeRect(kDotRadius, self.frame.size.height - kDotDiameter - kDotRadius, kDotDiameter, kDotDiameter);
    self.secondaryDotRect = NSMakeRect(self.frame.size.width-kDotDiameter-kDotRadius, kDotRadius, kDotDiameter, kDotDiameter);
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    [[NSColor blackColor] set];
    NSBezierPath* circle = [NSBezierPath bezierPathWithOvalInRect:self.dotRect];
    [circle fill];
    
    [[NSColor blackColor] set];
    NSBezierPath* line = [[NSBezierPath alloc] init];
    [line setLineWidth:3];
    
    CGFloat height = self.frame.size.height-1;
    CGFloat width = self.frame.size.width-1;
    
    [line moveToPoint:NSMakePoint(1, 1)];
    [line lineToPoint:NSMakePoint(1, height)];
    [line lineToPoint:NSMakePoint(width, height)];
    [line lineToPoint:NSMakePoint(width, 1)];
    [line lineToPoint:NSMakePoint(1, 1)];
    [line closePath];
    
    [line stroke];
    
    if (self.collapsed) {
        [[NSColor blackColor] set];
        NSBezierPath* circle = [NSBezierPath bezierPathWithOvalInRect:self.secondaryDotRect];
        [circle fill];
    }
}

- (NSPoint)locationForTitleViewBasedOn:(NSSize)size
{
    return NSMakePoint(self.frame.size.width-size.width, self.frame.size.height-size.height);
}

@end
