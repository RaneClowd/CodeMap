//
//  CMInvocationNode.m
//  CodeMap
//
//  Created by Kenny Skaggs on 1/28/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import "CMInvocationNode.h"

@implementation CMInvocationNode

- (NSString *)description
{
    return [NSString stringWithFormat:@" [ %@  %@ ]", [self.target description], [self.selector description]];
}

@end
