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

@implementation CMConnectorView

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
