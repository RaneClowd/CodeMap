//
//  CMMethod.m
//  CodeMap
//
//  Created by Kenny Skaggs on 2/2/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import "CMMethodView.h"
#import "CMNode.h"
#import "CMInvocationNode.h"
#import "CMValueView.h"

@interface CMMethodView ()

@property (nonatomic, strong) NSTextView* signatureView;

@end

@implementation CMMethodView

- (id)initWithFrame:(NSRect)frame andSignature:(NSString *)signature andExecutionNode:(CMNodeView *)node
{
    self = [super initWithFrame:frame];
    
    self.signatureView = [[NSTextView alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    [self.signatureView setFont:[NSFont systemFontOfSize:20]];
    [self.signatureView setEditable:NO];
    [self.signatureView setSelectable:NO];
    [self.signatureView setString:signature];
    [self.signatureView setDrawsBackground:NO];
    [self addSubview:self.signatureView];
    
    CGFloat max = 0;
    [self addViewForExecutionNode:node atX:0 andY:0 trackingMaxY:&max];
    
    [self positionSignature];
    
    return self;
}

- (void)setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
    [self positionSignature];
}

- (void)positionSignature
{
    self.signatureView.frame = CGRectMake(0, self.frame.size.height-50, 200, 50);
}

- (void)drawRect:(NSRect)rect
{
    [[NSColor colorWithCalibratedRed:0.3203 green:0.4023 blue:0.7773 alpha:1] set];
    NSRectFill(self.bounds);
    
    [super drawRect:rect];
    
    //[self.signatureView setNeedsDisplay:YES];
}


- (void)addViewForExecutionNode:(CMNode*)node atX:(CGFloat)x andY:(CGFloat)y trackingMaxY:(CGFloat*)maxY
{
    if (*maxY < y) *maxY = y;
    [self addNewViewFor:node atX:x andY:y];
    if (node.nextInLine) [self addViewForExecutionNode:node.nextInLine atX:x andY:y+60 trackingMaxY:maxY];
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
    nodeLabel = [self createNodeViewWithFrame:CGRectMake(x, y, 100, 30) andNode:node];
    
    [self addSubview:nodeLabel];
}

- (CMValueView*)createNodeViewWithFrame:(CGRect)frame andNode:(CMNode*)node
{
    CMValueView* label = [[CMValueView alloc] initWithFrame:frame];
    [label setString:[node myDescription]];
    label.displayDelegate = self;
    node.nodeView = label;
    return label;
}

@end
