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

@interface CMConnectorView ()

@property (nonatomic) NSPoint oldLocation;
@property (nonatomic,strong) CMNodeView* draggingView;

@end

@implementation CMConnectorView

- (void)mouseDown:(NSEvent *)theEvent
{
    self.oldLocation = [self convertPoint:theEvent.locationInWindow fromView:nil];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    NSPoint mouseLocation = [self convertPoint:theEvent.locationInWindow fromView:nil];
    
    if (self.draggingView == nil) {
        for (id<CMPYGraphNode> classNode in self.classNodes) {
            if (NSPointInRect(mouseLocation, [[classNode getView] frame])) {
                NSPoint relMouseLocation = [[classNode getView] convertPoint:mouseLocation fromView:self];
                for (id<CMPYGraphNode> method in [classNode getChildren]) {
                    if (NSPointInRect(relMouseLocation, [[method getView] frame])) {
                        self.draggingView = [method getView];
                        break;
                    }
                }
                
                if (self.draggingView == nil) self.draggingView = [classNode getView];
                break;
            }
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

- (void)mouseUp:(NSEvent *)theEvent
{
    self.draggingView = nil;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor blackColor] set];
    
    for (id<CMPYGraphNode> class in self.classNodes) {
        //[rootNode.nodeView setNeedsDisplay:YES];
        for (id<CMPYGraphNode> methodNode in [class getChildren]) {
            for (id<CMPYGraphNode> invocation in [methodNode getChildren]) {
                id<CMPYGraphNode> target = [invocation getTarget];
                if (target) {
                    [self drawLineFrom:invocation to:[invocation getTarget]];
                }
            }
        }
    }
}

- (BOOL)isOpaque
{
    return NO;
}

- (void)drawLineFrom:(id<CMPYGraphNode>)nodeA to:(id<CMPYGraphNode>)nodeB
{
    NSBezierPath* line = [[NSBezierPath alloc] init];
    [line setLineWidth:3];
    [line moveToPoint:[[nodeA getView] connectorPoint]];
    [line lineToPoint:[[nodeB getView] connectorPoint]];
    [line closePath];
    
    [line stroke];
}

@end
