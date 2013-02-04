//
//  CMMapDisplayView.m
//  CodeMap
//
//  Created by Kenny Skaggs on 2/1/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import "CMMapDisplayView.h"

#import "CMNode.h"
#import "CMNodeView.h"
#import "CMInvocationNode.h"
#import "CMMethodNode.h"
#import "CMMethodView.h"

@interface CMMapDisplayView () <DisplayDelegate>

@property (nonatomic,strong) NSMutableArray* rootNodes;

@end

@implementation CMMapDisplayView

- (id)initWithFrame:(NSRect)frame andNodes:(NSArray *)nodes
{
    self = [super initWithFrame:frame];
    if (self) {
        self.rootNodes = [[NSMutableArray alloc] init];
        
        CGFloat maxY = 800;
        CGFloat x = 200;
        
        [self setAutoresizesSubviews:NO];
        
        for (CMNode* node in nodes) {
            CGFloat y = 150;
            
            [self.rootNodes addObject:node];
            
            [self addNewViewFor:node atX:x andY:y];
            [self addViewForExecutionNode:((CMMethodNode*)node).firstExecutionNode atX:x andY:y+200 trackingMaxY:&maxY];
            
            x += 300;
        }
        
        CGRect newFrame = frame;
        newFrame.size.width = x;
        newFrame.size.height = maxY;
        
        self.frame = newFrame;
    }

    return self;
}

- (void)addViewForExecutionNode:(CMNode*)node atX:(CGFloat)x andY:(CGFloat)y trackingMaxY:(CGFloat*)maxY
{
    if (*maxY < y) *maxY = y;
    [self addNewViewFor:node atX:x andY:y];
    if (node.nextInLine) [self addViewForExecutionNode:node.nextInLine atX:x andY:y+200 trackingMaxY:maxY];
}

- (void)addNewViewFor:(CMNode*)node atX:(CGFloat)x andY:(CGFloat)y
{
    [self createAndAddViewFor:node atX:x andY:y];
    
    if ([node class] == [CMInvocationNode class]) {
        CMInvocationNode* invocationNode = (CMInvocationNode*)node;
        
        if (invocationNode.selector) {
            [self addNewViewFor:invocationNode.target atX:x andY:y];
            [self addNewViewFor:invocationNode.selector atX:x andY:y];
        }
    }
    
    for (CMNode* childNode in [node childNodes]) {
        [self addNewViewFor:childNode atX:x andY:y];
    }
}

- (void)createAndAddViewFor:(CMNode*)node atX:(CGFloat)x andY:(CGFloat)y
{
    CMNodeView* nodeLabel;
    if ([node class] == [CMMethodNode class]) {
        nodeLabel = [self createMethodNodeViewWithFrame:CGRectMake(x, y, 400, 400) andNode:(CMMethodNode*)node];
    } else {
        nodeLabel = [self createNodeViewWithFrame:CGRectMake(x, y, 100, 30) andNode:node];
    }
    
    [self addSubview:nodeLabel];
}

- (CMNodeView*)createNodeViewWithFrame:(CGRect)frame andNode:(CMNode*)node
{
    CMNodeView* label = [[CMNodeView alloc] initWithFrame:frame];
    [label setString:[node myDescription]];
    label.displayDelegate = self;
    node.nodeView = label;
    return label;
}

- (CMNodeView*)createMethodNodeViewWithFrame:(CGRect)frame andNode:(CMMethodNode*)node
{
    CMMethodView* label = [[CMMethodView alloc] initWithFrame:frame andSignature:node.value];
    label.displayDelegate = self;
    node.nodeView = label;
    return label;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor blackColor] set];
    
    for (CMNode* rootNode in self.rootNodes) {
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
        
        if (invocationNode.selector) {
            [self connectNode:invocationNode toNode:invocationNode.target];
            [self connectNode:invocationNode toNode:invocationNode.selector];
        } else {
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

- (void)redraw
{
    [self setNeedsDisplay:YES];
}

- (void)drawLineFrom:(CMNode*)nodeA to:(CMNode*)nodeB
{
    NSBezierPath* line = [[NSBezierPath alloc] init];
    [line setLineWidth:3];
    [line moveToPoint:[nodeA.nodeView getCenter]];
    [line lineToPoint:[nodeB.nodeView getCenter]];
    [line closePath];
    
    [line stroke];
}

@end
