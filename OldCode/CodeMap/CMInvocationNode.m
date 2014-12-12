//
//  CMInvocationNode.m
//  CodeMap
//
//  Created by Kenny Skaggs on 1/28/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import "CMInvocationNode.h"

@implementation CMInvocationNode

- (NSString *)myDescription
{
    return [NSString stringWithFormat:@"Invoke: [ %@ <> %@ ]", [self.target myDescription], [self.selector myDescription]];
}

@end
