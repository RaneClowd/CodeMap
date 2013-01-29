//
//  CMInvocationNode.m
//  CodeMap
//
//  Created by Kenny Skaggs on 1/28/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import "CMInvocationNode.h"

@implementation CMInvocationNode

- (id)initWithSelector:(NSString *)code andTarget:(NSString *)target
{
    self = [super initWithCode:code];
    self.target = target;
    return self;
}

@end