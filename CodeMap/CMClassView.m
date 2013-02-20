//
//  CMClassView.m
//  CodeMap
//
//  Created by Kenny Skaggs on 2/9/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import "CMClassView.h"
#import "CMMethodView.h"
#import "CMColors.h"

@interface CMClassView ()

@property (nonatomic,strong) NSColor* classColor;

@end

@implementation CMClassView

- (id)initWithLocation:(NSPoint)location Node:(id<CMPYGraphNode>)classNode
{
    self = [super initWithLocation:location size:80 andTitle:[classNode getText]];
    
    NSString* classType = (NSString*)[classNode getType];
    if ([classType isEqualToString:@"Interface"]) {
        self.classColor = [CMColors interfacedColor];
    } else if ([classType isEqualToString:@"Implementation"]) {
        self.classColor = [CMColors implementatedColor];
    }
    
    CGFloat maxY = 400;
    CGFloat x = 50;
        
    for (id<CMPYGraphNode> node in [classNode getChildren]) {
        CGFloat y = 100;
            
        [self createAndAddViewFor:node atX:x andY:y trackingY:&maxY];
            
        x += 400;
    }
        
    maxY += 300;
        
    CGRect newFrame = CGRectMake(location.x, location.y, MAX(self.titleView.frame.size.width + 80, x), maxY);
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
    [self.classColor set];
    NSRectFill(dirtyRect);
    
    [super drawRect:dirtyRect];
}

@end
