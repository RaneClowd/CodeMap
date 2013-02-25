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
@property (nonatomic,weak) id<CMPYGraphNode> classNode;
@property (nonatomic) BOOL hasBeenExpanded;

@end

@implementation CMClassView

- (id)initWithNode:(id<CMPYGraphNode>)classNode andLocation:(NSPoint)location
{
    self = [super initWithLocation:location size:80 andTitle:[classNode getText]];
    
    self.classNode = classNode;
    
    NSString* classType = (NSString*)[self.classNode getType];
    if ([classType isEqualToString:@"interface"]) {
        self.classColor = [CMColors interfacedColor];
    } else if ([classType isEqualToString:@"implementation"]) {
        self.classColor = [CMColors implementatedColor];
    }
    
    [self toggleCollapsed];
    
    return self;
}

- (void)createAndAddViewFor:(id<CMPYGraphNode>)node atX:(CGFloat)x andY:(CGFloat)y trackingY:(CGFloat*)maxY
{
    CMNodeView* nodeLabel = [self createMethodNodeViewWithFrame:NSMakePoint(x, y) andNode:node];
    
    CGFloat methodHeight = nodeLabel.frame.size.height;
    if (methodHeight > *maxY) *maxY = methodHeight;
    
    [self addSubview:nodeLabel];
}

- (void)toggleCollapsed
{
    if (self.collapsed && !self.hasBeenExpanded) {
        self.hasBeenExpanded = YES;
        [self firstExpand];
        [((id<CMSuperView>)self.superview) expandIfNeededToContainFrame:self.frame];
    } else {
        [super toggleCollapsed];
    }
}

- (void)firstExpand
{
    CGFloat maxY = 400;
    CGFloat x = 50;
    
    for (id<CMPYGraphNode> node in [self.classNode getChildren]) {
        CGFloat y = 100;
        
        [self createAndAddViewFor:node atX:x andY:y trackingY:&maxY];
        
        x += 400;
    }
    
    maxY += 300;
    
    CGRect newFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y, MAX(self.titleView.frame.size.width + 80, x), maxY);
    self.frame = newFrame;
}

- (CMNodeView*)createMethodNodeViewWithFrame:(NSPoint)location andNode:(id<CMPYGraphNode>)node
{
    CMMethodView* label = [[CMMethodView alloc] initWithLocation:location andNode:node];
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
