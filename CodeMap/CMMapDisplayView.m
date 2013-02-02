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
        CGFloat x = 100;
        
        [self setAutoresizesSubviews:NO];
        
        for (CMNode* node in nodes) {
            CGFloat y = 100;
            
            [self.rootNodes addObject:node];
            
            [self addNewViewFor:node atX:x andY:y trackingMaxY:&maxY];
            
            x += 110;
        }
        
        CGRect newFrame = frame;
        newFrame.size.width = x;
        newFrame.size.height = maxY;
        
        self.frame = newFrame;
    }

    return self;
}

- (void)addNewViewFor:(CMNode*)node atX:(CGFloat)x andY:(CGFloat)y trackingMaxY:(CGFloat*)maxY
{
    if (*maxY < y) *maxY = y;
    
    [self createAndAddViewFor:node atX:x andY:y];
    
    if ([node class] == [CMInvocationNode class]) {
        CMInvocationNode* invocationNode = (CMInvocationNode*)node;
        [self addNewViewFor:invocationNode.target atX:x andY:y trackingMaxY:maxY];
        [self addNewViewFor:invocationNode.selector atX:x andY:y trackingMaxY:maxY];
    }
    
    for (CMNode* childNode in [node childNodes]) {
        [self addNewViewFor:childNode atX:x andY:y+200 trackingMaxY:maxY];
    }
}

- (void)createAndAddViewFor:(CMNode*)node atX:(CGFloat)x andY:(CGFloat)y
{
    CMNodeView* nodeLabel = [self createNodeViewWithFrame:CGRectMake(x, y, 100, 30) andNode:node];
    [nodeLabel setString:[node myDescription]];
    [self addSubview:nodeLabel];
}

- (CMNodeView*)createNodeViewWithFrame:(CGRect)frame andNode:(CMNode*)node
{
    CMNodeView* label = [[CMNodeView alloc] initWithFrame:frame];
    label.displayDelegate = self;
    node.nodeView = label;
    return label;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor blackColor] set];
    
    for (CMNode* rootNode in self.rootNodes) {
        [self connectNodeFamilyTree:rootNode];
    }
}

- (void)connectNodeFamilyTree:(CMNode*)parentNode
{
    if ([parentNode class] == [CMInvocationNode class]) {
        CMInvocationNode* invocationNode = (CMInvocationNode*)parentNode;
        [self connectNode:invocationNode toNode:invocationNode.target];
        [self connectNode:invocationNode toNode:invocationNode.selector];
    }
    
    for (CMNode* childNode in parentNode.childNodes) {
        [self connectNode:parentNode toNode:childNode];
    }
}

- (void)connectNode:(CMNode*)parentNode toNode:(CMNode*)childNode
{
    [self drawLineFrom:[parentNode.nodeView getCenter] to:[childNode.nodeView getCenter]];
    [self connectNodeFamilyTree:childNode];
}

- (void)redraw
{
    [self setNeedsDisplay:YES];
}

- (void)drawLineFrom:(CGPoint)pointA to:(CGPoint)pointB
{
    NSBezierPath* line = [[NSBezierPath alloc] init];
    [line setLineWidth:3];
    [line moveToPoint:pointA];
    [line lineToPoint:pointB];
    [line closePath];
    
    [line stroke];
}

@end
