//
//  CMNodeView.m
//  CodeMap
//
//  Created by Kenny Skaggs on 1/30/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import "CMNodeView.h"

@implementation CMNodeView

- (NSPoint)connectorPoint
{
    return NSMakePoint(self.frame.origin.x + self.frame.size.width/2, self.frame.origin.y + self.frame.size.height/2);
}

- (BOOL)isOpaque
{
    return YES;
}

@end
