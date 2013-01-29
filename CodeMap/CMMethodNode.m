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

@end
