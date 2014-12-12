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

@property NSColor* self;
@property (nonatomic,strong) NSColor* classColor;
@property (nonatomic,weak) id<CMPYGraphNode> classNode;
@property (nonatomic) BOOL hasBeenExpanded;

@property (nonatomic,strong) NSMutableDictionary* nullPropertyCatcher;

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
    self.nullPropertyCatcher = [[NSMutableDictionary alloc] init];
    
    [self toggleCollapsed];
    
    return self;
}

- (void)expandIfNeededToContainChild:(NSView *)child
{
    CGFloat childLeftBound = child.frame.origin.x;
    BOOL leftExceeded = childLeftBound < 0;
    
    CGFloat childBottomBound = child.frame.origin.y;
    BOOL bottomExceeded = childBottomBound < 0;
    
    CGFloat childRightBound = childLeftBound + child.frame.size.width;
    CGFloat selfRightBound = self.frame.size.width;
    BOOL rightExceeded = selfRightBound < childRightBound;
    
    CGFloat childTopBound = childBottomBound + child.frame.size.height;
    CGFloat selfTopBound = self.frame.size.height;
    BOOL topExceeded = selfTopBound < childTopBound;
    
    if (topExceeded || rightExceeded || bottomExceeded || leftExceeded) {
        CGRect newFrame = self.frame;
        
        if (topExceeded) newFrame.size.height = childTopBound;
        if (rightExceeded) newFrame.size.width = childRightBound;
        if (leftExceeded) {
            newFrame.origin.x += childLeftBound;
            newFrame.size.width -= childLeftBound;
            
            CGRect childFrame = child.frame;
            childFrame.origin.x = 0;
            [child setFrame:childFrame];
        }
        if (bottomExceeded) {
            newFrame.origin.y += childBottomBound;
            newFrame.size.height -= childBottomBound;
            
            CGRect childFrame = child.frame;
            childFrame.origin.y = 0;
            [child setFrame:childFrame];
        }
        
        [self setFrame:newFrame];
    }
    
    //[self.myDisplayDel expandIfNeededToContainFrame:self.frame];
}

- (void)toggleCollapsed
{
    if (self.collapsed && !self.hasBeenExpanded) {
        self.hasBeenExpanded = YES;
        self.collapsed = NO;
        [self firstExpand];
        [((id<CMSuperView>)self.superview) expandIfNeededToContainChild:self];
    } else {
        [super toggleCollapsed];
    }
}

- (void)firstExpand
{
    CGFloat maxY = 400;
    CGFloat x = 50;
    
    NSMutableDictionary* subTargetingAssistant = [NSMutableDictionary new];
    
    for (id<CMPYGraphNode> node in [self.classNode getChildren]) {
        CGFloat y = 100;
        
        [self createAndAddViewFor:node atX:x andY:y trackingY:&maxY targetingAssistant:subTargetingAssistant];
        
        x += 400;
    }
    
    for (CMNodeView* listenerView in self.listenerCollection) {
        NSUInteger subTargetingCount = [listenerView.subTargeting count];
        if (subTargetingCount > 0) {
            NSString* subTargetKey = listenerView.subTargeting[0];
            CMNodeView* newTarget = [subTargetingAssistant objectForKey:subTargetKey];
            [listenerView setTarget:newTarget];
            
            NSMutableArray* newSubTargetting = [NSMutableArray arrayWithArray:[listenerView.subTargeting subarrayWithRange:NSMakeRange(1, subTargetingCount-1)]];
            listenerView.subTargeting = newSubTargetting;
        }
    }
    
    for (id<CMPYGraphNode> classChild in [self.classNode getChildren]) {
        if ([[classChild getType] isEqualToString:@"1method"]) {
            for (id<CMPYGraphNode> methodChild in [classChild getChildren]) {
                NSArray* targets = [methodChild getTargets];
                if ([[methodChild getType] isEqualToString:@"2methodcall"] && [targets count] > 0) {
                    id firstTarget = targets[0];
                    if ([firstTarget respondsToSelector:@selector(getTargets)]) {
                        CMNodeView* targetView = [firstTarget getView];
                        if (!targetView) {
                            targetView = [self.nullPropertyCatcher objectForKey:[firstTarget getHash]];
                        }
                        
                        CMNodeView* methodChildView = [methodChild getView];
                        [methodChildView setTarget:targetView];
                        
                        for (int i=1; i < [targets count]; i++) {
                            [methodChildView.subTargeting addObject:targets[i]];
                        }
                    }
                }
            }
        }
    }
    
    maxY += 300;
    
    CGRect newFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y, MAX(self.titleView.frame.size.width + 80, x), maxY);
    self.frame = newFrame;
    [((id<CMSuperView>)self.superview) expandIfNeededToContainChild:self];
}

- (void)createAndAddViewFor:(id<CMPYGraphNode>)node atX:(CGFloat)x andY:(CGFloat)y trackingY:(CGFloat*)maxY targetingAssistant:(NSMutableDictionary*)targetingAssistant
{
    CMNodeView* nodeView;
    
    if ([[node getType] isEqualToString:@"1method"] || [[node getType] isEqualToString:@"?"]) {
        nodeView = [self createMethodNodeViewWithFrame:NSMakePoint(x, y) andNode:node];
    } else {
        id<CMPYGraphNode> classNode = [CMClassNodeCollection classNodeForClassName:[node getType]];
        if (classNode) {
            nodeView = [self createClassNodeViewWithFrame:NSMakePoint(x, y) andNode:node];
        } else {
            nodeView = [self createMethodNodeViewWithFrame:NSMakePoint(x, y) andNode:node];
        }
    }
    
    [node setView:nodeView];
    if (![node getView]) {
        [self.nullPropertyCatcher setObject:nodeView forKey:[node getHash]];
    }
    
    [targetingAssistant setObject:nodeView forKey:[node getTargetingKey]];
    
    CGFloat nodeHeight = nodeView.frame.size.height;
    if (nodeHeight > *maxY) *maxY = nodeHeight;
    
    [self addSubview:nodeView];
}

- (CMNodeView*)createMethodNodeViewWithFrame:(NSPoint)location andNode:(id<CMPYGraphNode>)node
{
    CMMethodView* label = [[CMMethodView alloc] initWithLocation:location andNode:node];
    label.displayDelegate = self;
    return label;
}

- (CMNodeView*)createClassNodeViewWithFrame:(NSPoint)location andNode:(id<CMPYGraphNode>)node
{
    CMClassView* label = [[CMClassView alloc] initWithNode:node andLocation:location];
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
