//
//  CMCodeNode.m
//  CodeMap
//
//  Created by Kenny Skaggs on 1/26/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import "CMCodeNode.h"

@implementation CMCodeNode

- (NSString *)description
{
    return [NSString stringWithFormat:@"Code: %@", self.value];
}

@end