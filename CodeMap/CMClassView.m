//
//  CMClassView.m
//  CodeMap
//
//  Created by Kenny Skaggs on 2/9/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import "CMClassView.h"
#import "CMMethodView.h"

@implementation CMClassView

- (id)initWithLocation:(NSPoint)location Node:(id<CMPYGraphNode>)classNode
{
    self = [super init];
    
    CGFloat maxY = 400;
    CGFloat x = 50;
        
    for (id<CMPYGraphNode> node in [classNode getChildren]) {
        CGFloat y = 100;
            
        [self createAndAddViewFor:node atX:x andY:y trackingY:&maxY];
            
        x += 400;
    }
        
    maxY += 300;
        
    CGRect newFrame = CGRectMake(location.x, location.y, x, maxY);
    self.frame = newFrame;
    
    return self;
}

- (void)createAndAddViewFor:(id<CMPYGraphNode>)node atX:(CGFloat)x andY:(CGFloat)y trackingY:(CGFloat*)maxY
{
    CMNodeView* nodeLabel = [self createMethodNodeViewWithFrame:NSMakePoint(x, y) andNode:node];
    
    CGFloat methodHeight = nodeLabel.frame.size.height;
    if (methodHeight > *maxY) *maxY = methodHeight;
    
    [self addSubview:nodeLabel];
}

- (CMNodeView*)createMethodNodeViewWithFrame:(NSPoint)location andNode:(id<CMPYGraphNode>)node
{
    CMMethodView* label = [[CMMethodView alloc] initWithLocation:location andSignature:[node getText] andExecutionNodes:[node getChildren]];
    [node setView:label];
    label.displayDelegate = self;
    return label;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor colorWithCalibratedRed:0.3203 green:0.6023 blue:0.7773 alpha:1] set];
    NSRectFill(dirtyRect);
    
    [super drawRect:dirtyRect];
}

@end
