//
//  CMConnectorView.m
//  CodeMap
//
//  Created by Kenny Skaggs on 2/8/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import "CMConnectorView.h"
#import "CMNode.h"
#import "CMMethodNode.h"
#import "CMMethodView.h"

@interface CMConnectorView ()

@property (nonatomic) NSPoint oldLocation;
@property (nonatomic,strong) CMNodeView* draggingView;

@end

@implementation CMConnectorView

- (void)mouseDown:(NSEvent *)theEvent
{
    self.oldLocation = [self relativeMouseLocationFromEvent:theEvent];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    NSPoint mouseLocation = [self relativeMouseLocationFromEvent:theEvent];
    
    if (self.draggingView == nil) {
        for (CMMethodNode* node in self.nodes) {
            if (NSPointInRect(mouseLocation, node.nodeView.frame)) {
                self.draggingView = (CMMethodView*)node.nodeView;
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

- (NSPoint)relativeMouseLocationFromEvent:(NSEvent*)event
{
    return [self convertPoint:event.locationInWindow fromView:nil];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor blackColor] set];
    
    for (CMNode* rootNode in self.nodes) {
        //[rootNode.nodeView setNeedsDisplay:YES];
        
        [self connectNodeFamilyTree:rootNode];
        [self connectLevelsOfExecution:((CMMethodNode*)rootNode).firstExecutionNode];
    }
}

- (void)connectLevelsOfExecution:(CMNode*)executionNode
{
    [self connectNodeFamilyTree:executionNode];
    if (executionNode.nextInLine) [self connectLevelsOfExecution:executionNode.nextInLine];
}

- (void)connectNodeFamilyTree:(CMNode*)parentNode
{
    if ([parentNode class] == [CMInvocationNode class]) {
        CMInvocationNode* invocationNode = (CMInvocationNode*)parentNode;
        
        if (!invocationNode.selector) {
            [self drawLineFrom:invocationNode to:invocationNode.target];
        }
    }
    
    for (CMNode* childNode in parentNode.childNodes) {
        [self connectNode:parentNode toNode:childNode];
    }
}

- (void)connectNode:(CMNode*)parentNode toNode:(CMNode*)childNode
{
    [self drawLineFrom:parentNode to:childNode];
    [self connectNodeFamilyTree:childNode];
}

- (BOOL)isOpaque
{
    return NO;
}

- (void)drawLineFrom:(CMNode*)nodeA to:(CMNode*)nodeB
{
    NSBezierPath* line = [[NSBezierPath alloc] init];
    [line setLineWidth:3];
    [line moveToPoint:[nodeA.nodeView connectorPoint]];
    [line lineToPoint:[nodeB.nodeView connectorPoint]];
    [line closePath];
    
    [line stroke];
}

@end
