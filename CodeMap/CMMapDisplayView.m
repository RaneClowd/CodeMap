//
//  CMMapDisplayView.m
//  CodeMap
//
//  Created by Kenny Skaggs on 2/1/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import "CMMapDisplayView.h"

#import "CMNode.h"
#import "CMValueView.h"
#import "CMInvocationNode.h"
#import "CMMethodNode.h"
#import "CMMethodView.h"
#import "CMConnectorView.h"

@interface CMMapDisplayView () <DisplayDelegate>

@property (nonatomic,strong) NSMutableArray* rootNodes;
@property (nonatomic,strong) CMConnectorView* connectionView;

@end

@implementation CMMapDisplayView

- (id)initWithFrame:(NSRect)frame andNodes:(NSArray *)nodes
{
    self = [super initWithFrame:frame];
    if (self) {
        self.rootNodes = [[NSMutableArray alloc] init];
        
        CGFloat maxY = 800;
        CGFloat x = 200;
        
        //[self setAutoresizesSubviews:NO];
        
        for (CMNode* node in nodes) {
            CGFloat y = 150;
            
            [self.rootNodes addObject:node];
            
            [self addNewViewFor:node atX:x andY:y];
            
            x += 300;
        }
        
        CGRect newFrame = frame;
        newFrame.size.width = x;
        newFrame.size.height = maxY;
        
        self.frame = newFrame;
        
        self.connectionView = [[CMConnectorView alloc] initWithFrame:newFrame];
        self.connectionView.nodes = self.rootNodes;
        [self addSubview:self.connectionView];
        
        self.bounds = CGRectMake(0, 0, x, maxY);
    }

    return self;
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

- (CMValueView*)createNodeViewWithFrame:(CGRect)frame andNode:(CMNode*)node
{
    CMValueView* label = [[CMValueView alloc] initWithFrame:frame andNode:node];
    label.displayDelegate = self;
    node.nodeView = label;
    return label;
}

- (CMNodeView*)createMethodNodeViewWithFrame:(CGRect)frame andNode:(CMMethodNode*)node
{
    CMMethodView* label = [[CMMethodView alloc] initWithFrame:frame andSignature:node.value andExecutionNode:node.firstExecutionNode];
    label.displayDelegate = self;
    node.nodeView = label;
    return label;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];

    [self.connectionView setNeedsDisplay:YES];
}

- (void)redraw
{
    [self setNeedsDisplay:YES];
}

@end
