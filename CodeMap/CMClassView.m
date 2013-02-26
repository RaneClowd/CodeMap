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
#import "CMClassNodeCollection.h"

@interface CMClassView ()

@property (nonatomic,strong) NSColor* classColor;
@property (nonatomic,weak) id<CMPYGraphNode> classNode;
@property (nonatomic) BOOL hasBeenExpanded;

@end

@implementation CMClassView

- (id)initWithNode:(id<CMPYGraphNode>)node andLocation:(NSPoint)location
{
    BOOL isProperty = NO;
    
    NSString* nodeType = (NSString*)[node getType];
    if ([nodeType isEqualToString:@"2interface"]) {
        self.classColor = [CMColors interfacedColor];
    } else if ([nodeType isEqualToString:@"2implementation"]) {
        self.classColor = [CMColors implementatedColor];
    } else {
        isProperty = YES;
        self.classColor = ([[node getPubliclyAccessible] isEqualToString:@"Yes"] ? [CMColors publicProperty] : [CMColors privateProperty]);
    }
    
    if (isProperty) {
        self = [super initWithLocation:location size:20 andTitle:[node getText]];
        self.classNode = [CMClassNodeCollection classNodeForClassName:[node getType]];
    } else {
        self = [super initWithLocation:location size:80 andTitle:[node getText]];
        self.classNode = node;
    }
    
    [self toggleCollapsed];
    
    return self;
}

- (void)expandIfNeededToContainFrame:(CGRect)frame
{
    CGFloat childRightBound = frame.origin.x + frame.size.width;
    CGFloat selfRightBound = self.frame.origin.x + self.frame.size.width;
    BOOL rightExceeded = selfRightBound < childRightBound;
    
    CGFloat childTopBound = frame.origin.y + frame.size.height;
    CGFloat selfTopBound = self.frame.origin.y + self.frame.size.height;
    BOOL topExceeded = selfTopBound < childTopBound;
    
    if (topExceeded || rightExceeded) {
        CGRect newFrame = self.frame;
        if (topExceeded) newFrame.size.height = childTopBound;
        if (rightExceeded) newFrame.size.width = childRightBound;
        [self setFrame:newFrame];
    }
    
    //[self.myDisplayDel expandIfNeededToContainFrame:self.frame];
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

- (void)createAndAddViewFor:(id<CMPYGraphNode>)node atX:(CGFloat)x andY:(CGFloat)y trackingY:(CGFloat*)maxY
{
    CMNodeView* nodeView;
    
    if ([[node getType] isEqualToString:@"1method"] || [[node getType] isEqualToString:@"?"]) {
        nodeView = [self createMethodNodeViewWithFrame:NSMakePoint(x, y) andNode:node];
    } else {
        id<CMPYGraphNode> classNode = [CMClassNodeCollection classNodeForClassName:[node getType]];
        if (classNode) {
            nodeView = [[CMClassView alloc] initWithNode:node andLocation:NSMakePoint(x, y)];
        } else {
            nodeView = [self createMethodNodeViewWithFrame:NSMakePoint(x, y) andNode:node];
        }
    }
    
    [node setView:nodeView];
    
    CGFloat nodeHeight = nodeView.frame.size.height;
    if (nodeHeight > *maxY) *maxY = nodeHeight;
    
    [self addSubview:nodeView];
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
