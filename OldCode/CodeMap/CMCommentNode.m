//
//  CMCommentNode.m
//  CodeMap
//
//  Created by Kenny Skaggs on 1/26/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import "CMCommentNode.h"

@implementation CMCommentNode

- (NSString *)myDescription
{
    return [NSString stringWithFormat:@"Comment: %@", self.value];
}

@end
