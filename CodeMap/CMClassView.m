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

- (id)initWithLocation:(NSPoint)location Node:(CMClassNode*)class
{
    self = [super init];
    class.nodeView = self;
    
    CGFloat maxY = 400;
    CGFloat x = 50;
        
    for (CMMethodNode* node in [class methods]) {
        CGFloat y = 100;
            
        [self createAndAddViewFor:node atX:x andY:y trackingY:&maxY];
            
        x += 400;
    }
        
    maxY += 300;
        
    CGRect newFrame = CGRectMake(location.x, location.y, x, maxY);
    self.frame = newFrame;
    
    return self;
}

- (void)createAndAddViewFor:(CMMethodNode*)node atX:(CGFloat)x andY:(CGFloat)y trackingY:(CGFloat*)maxY
{
    CMNodeView* nodeLabel = [self createMethodNodeViewWithFrame:CGRectMake(x, y, 400, 400) andNode:(CMMethodNode*)node];
    
    CGFloat methodHeight = nodeLabel.frame.size.height;
    if (methodHeight > *maxY) *maxY = methodHeight;
    
    [self addSubview:nodeLabel];
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
    [[NSColor colorWithCalibratedRed:0.3203 green:0.6023 blue:0.7773 alpha:1] set];
    NSRectFill(dirtyRect);
    
    [super drawRect:dirtyRect];
}

@end
