//
//  CMStringNode.m
//  CodeMap
//
//  Created by Kenny Skaggs on 1/26/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import "CMStringNode.h"

@implementation CMStringNode

- (NSString *)myDescription
{
    return [NSString stringWithFormat:@"String: %@", self.value];
}

@end
