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
}

- (void)redraw
{
    [self setNeedsDisplay:YES];
}

- (BOOL)isDraggable
{
    return YES;
}

@end
