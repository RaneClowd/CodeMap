//
//  CMDraggableView.m
//  CodeMap
//
//  Created by Kenny Skaggs on 2/4/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import "CMDraggableView.h"

@implementation CMDraggableView

- (void)mouseDragged:(NSEvent *)theEvent
{
    CGRect frame = self.frame;
    frame.origin.x += [theEvent deltaX];
    frame.origin.y -= [theEvent deltaY];
    self.frame = frame;
    
    [self.displayDelegate redraw];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
}

- (void)redraw
{
    [self setNeedsDisplay:YES];
}

@end
