//
//  CMMethod.m
//  CodeMap
//
//  Created by Kenny Skaggs on 2/2/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import "CMMethodView.h"
#import "CMValueView.h"
#import "CMColors.h"

#define kDotDiameter 14
#define kDotRadius 7

#define kSignatureHeight 50
#define kValueHeight 30

@interface CMMethodView ()

@property (nonatomic, strong) NSTextView* signatureView;
@property (nonatomic) NSRect dotRect;

@property (nonatomic) NSColor* backColor;

@end

@implementation CMMethodView

- (id)initWithLocation:(NSPoint)location andNode:(id<CMPYGraphNode>)node
{
    NSUInteger numberOfCalls = [[node getChildren] count];
    
    if ([[node getType] isEqualToString:@"1method"]) {
        if ([[node getPubliclyAccessible] isEqualToString:@"Yes"]) self.backColor = [CMColors publicMethod];
        else self.backColor = [CMColors privateMethod];
    } else {
        if ([[node getPubliclyAccessible] isEqualToString:@"Yes"]) self.backColor = [CMColors publicProperty];
        else self.backColor = [CMColors privateProperty];
    }
    
    self = [super initWithLocation:location size:20 andTitle:[node getText]];
    
    CGFloat widthNeeded = self.titleView.frame.size.width + kDotDiameter*2;
    CGFloat posY = (numberOfCalls-1) * kValueHeight;
    for (id<CMPYGraphNode> methodCall in [node getChildren]) {
        [self addViewForExecutionNode:methodCall atY:posY trackingWidth:&widthNeeded];
        posY -= kValueHeight;
    }
    
    for (NSView* subView in self.subviews) {
        if ([[subView class] isSubclassOfClass:[CMNodeView class]]) {
            CGRect frame = subView.frame;
            frame.size.width = widthNeeded;
            subView.frame = frame;
        }
    }
    
    CGRect newFrame = self.frame;
    newFrame.size.height = numberOfCalls*kValueHeight + kSignatureHeight;
    newFrame.size.width = widthNeeded;
    self.frame = newFrame;
    
    return self;
}

- (void)setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
    
    self.dotRect = NSMakeRect(kDotRadius, self.frame.size.height - kDotDiameter - kDotRadius, kDotDiameter, kDotDiameter);
}

- (NSPoint)connectorPoint
{
    return NSMakePoint([self relativeX]+self.dotRect.origin.x+kDotRadius, [self relativeY]+self.dotRect.origin.y+kDotRadius);
}

- (void)drawRect:(NSRect)rect
{
    [self.backColor set];
    NSRectFill(self.bounds);
    
    [super drawRect:rect];
    
    [[NSColor blackColor] set];
    NSBezierPath* circle = [NSBezierPath bezierPathWithOvalInRect:self.dotRect];
    [circle fill];
}

- (void)addViewForExecutionNode:(id<CMPYGraphNode>)node atY:(CGFloat)posY trackingWidth:(CGFloat*)width
{
    [self addNewViewFor:node atY:posY trackingWidth:width];
}

- (void)addNewViewFor:(id<CMPYGraphNode>)node atY:(CGFloat)posY trackingWidth:(CGFloat*)width
{
    [self createAndAddViewFor:node atY:posY trackingWidth:(CGFloat*)width];
    
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

- (void)createAndAddViewFor:(id<CMPYGraphNode>)node atY:(CGFloat)posY trackingWidth:(CGFloat*)width
{
    CMValueView* nodeLabel;
    nodeLabel = [self createNodeViewWithFrame:CGRectMake(0, posY, self.frame.size.width, kValueHeight) andNode:node];
    
    [node setView:nodeLabel];
    
    if (*width < [nodeLabel widthNeeded]) *width = [nodeLabel widthNeeded];
    
    [self addSubview:nodeLabel];
}

- (CMValueView*)createNodeViewWithFrame:(CGRect)frame andNode:(id<CMPYGraphNode>)node
{
    CMValueView* label = [[CMValueView alloc] initWithFrame:frame andNode:node];
    label.displayDelegate = self;
    return label;
}

@end
