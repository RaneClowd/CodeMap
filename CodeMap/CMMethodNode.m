//
//  CMMethodNode.m
//  CodeMap
//
//  Created by Kenny Skaggs on 1/26/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import "CMMethodNode.h"

@implementation CMMethodNode

- (NSString *)myDescription
{
    return [NSString stringWithFormat:@"Method: %@", [super myDescription]];
}

- (void)addNodeOfExecution:(CMNode *)node
{
    if (self.lastExecutionNode) {
        self.lastExecutionNode.nextInLine = node;
        self.lastExecutionNode = node;
    } else {
        /*
         check that this works
         */
        self.firstExecutionNode = self.lastExecutionNode = node;
    }
}

@end
