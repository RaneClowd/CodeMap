//
//  CMImportNode.m
//  CodeMap
//
//  Created by Kenny Skaggs on 1/27/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import "CMImportNode.h"

@implementation CMImportNode

- (NSString *)description
{
    return [NSString stringWithFormat:@"Import: %@", self.value];
}

@end
