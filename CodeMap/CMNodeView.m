//
//  CMNodeView.m
//  CodeMap
//
//  Created by Kenny Skaggs on 1/30/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import "CMNodeView.h"

@implementation CMNodeView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    [self setEditable:NO];
    [self setSelectable:NO];
    
    return self;
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    CGRect frame = self.frame;
    frame.origin.x += [theEvent deltaX];
    frame.origin.y -= [theEvent deltaY];
    self.frame = frame;
    
    [self.displayDelegate redraw];
}

- (CGPoint)getCenter
{
    return CGPointMake(self.frame.origin.x + self.frame.size.width/2, self.frame.origin.y + self.frame.size.height/2);
}

@end
