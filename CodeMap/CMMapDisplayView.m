//
//  CMMapDisplayView.m
//  CodeMap
//
//  Created by Kenny Skaggs on 2/1/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import "CMMapDisplayView.h"

#import "CMPYGraphNode.h"

#import "CMValueView.h"
#import "CMMethodView.h"
#import "CMConnectorView.h"
#import "CMClassView.h"
#import "CMClassNodeCollection.h"

@interface CMMapDisplayView () <DisplayDelegate>

@property (nonatomic,strong) CMConnectorView* connectionView;

@end

@implementation CMMapDisplayView

- (id)initWithFrame:(NSRect)frame andClasses:(NSArray *)classes
{
    self = [super initWithFrame:frame];
    if (self) {
        
        CGFloat maxY = 800;
        CGFloat x = 200;
        
        for (id<CMPYGraphNode> node in classes) {
            CGFloat y = 150;
            
            NSView* classView = [self createAndAddViewFor:node atX:x andY:y trackingY:&maxY];
            
            x += classView.frame.size.width + 30;
        }
        
        maxY += 500;
        
        CGRect newFrame = frame;
        newFrame.size.width = x;
        newFrame.size.height = maxY;
        
        self.frame = newFrame;
        
        self.connectionView = [CMConnectorView sharedInstance];
        [self.connectionView setFrame:newFrame];
        self.connectionView.classNodes = classes;
        [self addSubview:self.connectionView];
    }

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
    
    [self.connectionView setFrame:self.frame];
    [self.myDisplayDel expandIfNeededToContainFrame:self.frame];
}

- (NSView*)createAndAddViewFor:(id<CMPYGraphNode>)node atX:(CGFloat)x andY:(CGFloat)y trackingY:(CGFloat*)maxY
{
    CMClassView* classView = [self createClassViewWithLocation:NSMakePoint(x, y) andNode:node];
    [node setView:classView];
    
    CGFloat methodHeight = classView.frame.size.height;
    if (methodHeight > *maxY) *maxY = methodHeight;
        
    [self addSubview:classView];
    return classView;
}

- (CMClassView*)createClassViewWithLocation:(NSPoint)location andNode:(id<CMPYGraphNode>)classNode
{
    CMClassView* classView = [[CMClassView alloc] initWithNode:classNode andLocation:location];
    classView.displayDelegate = self;
    return classView;
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
