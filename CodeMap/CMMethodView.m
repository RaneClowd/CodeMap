//
//  CMMethod.m
//  CodeMap
//
//  Created by Kenny Skaggs on 2/2/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import "CMMethodView.h"
#import "CMInvocationNode.h"
#import "CMValueView.h"

#define kSignatureHeight 50
#define kValueHeight 30

@interface CMMethodView ()

@property (nonatomic, strong) NSTextView* signatureView;

@end

@implementation CMMethodView

- (id)initWithFrame:(NSRect)frame andSignature:(NSString *)signature andExecutionNode:(CMNode *)node
{
    self = [super initWithFrame:frame];
    
    self.signatureView = [[NSTextView alloc] initWithFrame:CGRectMake(0, 0, 200, kSignatureHeight)];
    [self.signatureView setFont:[NSFont systemFontOfSize:20]];
    [self.signatureView setEditable:NO];
    [self.signatureView setSelectable:NO];
    [self.signatureView setString:signature];
    [self.signatureView setDrawsBackground:NO];
    [self addSubview:self.signatureView];
    
    int count = 0;
    CGFloat widthNeeded = 0;
    [self addViewForExecutionNode:node trackingCount:&count trackingWidth:&widthNeeded];
    
    [self positionSignature];
    
    CGRect newFrame = self.frame;
    newFrame.size.height = count*kValueHeight + kSignatureHeight;
    newFrame.size.width = widthNeeded;
    self.frame = newFrame;
    
    [self positionExecutionViewForNode:node withCount:count-1 andWidth:widthNeeded];
    
    return self;
}

- (void)positionExecutionViewForNode:(CMNode*)node withCount:(int)count andWidth:(CGFloat)width
{
    CGRect frame = node.nodeView.frame;
    frame.origin.y = count * kValueHeight;
    frame.size.width = width;
    node.nodeView.frame = frame;
    
    if (node.nextInLine) {
        [self positionExecutionViewForNode:node.nextInLine withCount:count-1 andWidth:width];
    }
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


- (void)addViewForExecutionNode:(CMNode*)node trackingCount:(int*)count trackingWidth:(CGFloat*)width
{
    *count += 1;
    [self addNewViewFor:node trackingWidth:width];
    if (node.nextInLine) [self addViewForExecutionNode:node.nextInLine trackingCount:count trackingWidth:width];
}

- (void)addNewViewFor:(CMNode*)node trackingWidth:(CGFloat*)width
{
    [self createAndAddViewFor:node trackingWidth:(CGFloat*)width];
    
    /*if ([node class] == [CMInvocationNode class]) {
        CMInvocationNode* invocationNode = (CMInvocationNode*)node;
        
        if (invocationNode.selector) {
            [self addNewViewFor:invocationNode.target];
            [self addNewViewFor:invocationNode.selector];
        }
    }
    
    for (CMNode* childNode in [node childNodes]) {
        [self addNewViewFor:childNode];
    }*/
}

- (void)createAndAddViewFor:(CMNode*)node trackingWidth:(CGFloat*)width
{
    CMValueView* nodeLabel;
    nodeLabel = [self createNodeViewWithFrame:CGRectMake(0, 0, self.frame.size.width, kValueHeight) andNode:node];
    
    if (*width < [nodeLabel widthNeeded]) *width = [nodeLabel widthNeeded];
    
    [self addSubview:nodeLabel];
}

- (CMValueView*)createNodeViewWithFrame:(CGRect)frame andNode:(CMNode*)node
{
    CMValueView* label = [[CMValueView alloc] initWithFrame:frame andNode:node];
    label.displayDelegate = self;
    node.nodeView = label;
    return label;
}

@end
