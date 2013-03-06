//
//  CMConnectorView.m
//  CodeMap
//
//  Created by Kenny Skaggs on 2/8/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import "CMConnectorView.h"
#import "CMPYGraphNode.h"
#import "CMMethodView.h"
#import "CMClassView.h"

static CMConnectorView* shared;

@interface CMConnectorView ()

@property (nonatomic) NSPoint oldLocation;
@property (nonatomic,strong) CMNodeView* draggingView;

@end

@implementation CMConnectorView

+ (CMConnectorView *)sharedInstance
{
    if (!shared) {
        shared = [[CMConnectorView alloc] init];
    }
    
    return shared;
}

- (void)mouseDown:(NSEvent *)theEvent
{
    [super mouseDown:theEvent];
    self.oldLocation = [self convertPoint:theEvent.locationInWindow fromView:nil];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    NSPoint mouseLocation = [self convertPoint:theEvent.locationInWindow fromView:nil];
    
    if (self.draggingView == nil) {
        for (NSView* classView in self.classViews) {
            [self checkView:classView forDraggingAt:mouseLocation];
        }
    }
    
    if (self.draggingView != nil) {
        CGRect frame = self.draggingView.frame;
        frame.origin.x += mouseLocation.x - self.oldLocation.x;
        frame.origin.y += mouseLocation.y - self.oldLocation.y;
        self.draggingView.frame = frame;
        
        self.oldLocation = mouseLocation;
        
        [[self superview] setNeedsDisplay:YES];
    }
}

- (void)checkView:(NSView*)view forDraggingAt:(NSPoint)location
{
    if (NSPointInRect(location, [view frame])) {
        NSPoint locationRelToView = [view convertPoint:location fromView:[view superview]];
        for (NSView* subView in [view subviews]) {
            if ([[subView class] isSubclassOfClass:[CMContainerView class]]) {
                [self checkView:subView forDraggingAt:locationRelToView];
                if (self.draggingView) return;
            }
        }
        self.draggingView = (CMNodeView*)view;
    } else {
        return;
    }
}

- (void)mouseUp:(NSEvent *)theEvent
{
    [super mouseUp:theEvent];
    self.draggingView = nil;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor blackColor] set];
    
    for (CMNodeView* classView in self.classViews) {
        [self drawConnectorsOnClass:classView];
    }
}

- (void)drawConnectorsOnClass:(CMNodeView*)classView
{
    for (NSView* subView in classView.subviews) {
        if ([subView class] == [CMMethodView class]) {
            for (NSView* subSubView in subView.subviews) {
                if ([[subSubView class] isSubclassOfClass:[CMNodeView class]]) {
                    CMNodeView* converted = (CMNodeView*)subSubView;
                    if (converted.target) {
                        [self drawLineFrom:converted to:converted.target];
                    }
                }
            }
        } else if ([subView class] == [CMClassView class]) {
            [self drawConnectorsOnClass:(CMNodeView*)subView];
        }
    }
}

- (BOOL)isOpaque
{
    return NO;
}

- (void)drawLineFrom:(CMNodeView*)from to:(CMNodeView*)to
{
    NSBezierPath* line = [[NSBezierPath alloc] init];
    [line setLineWidth:3];
    [line moveToPoint:[from connectorPointIsTheTarget:NO]];
    [line lineToPoint:[to connectorPointIsTheTarget:YES]];
    [line closePath];
    
    [line stroke];
}

@end
