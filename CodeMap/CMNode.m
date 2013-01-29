//
//  CMNode.m
//  CodeMap
//
//  Created by Kenny Skaggs on 1/26/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import "CMNode.h"

@implementation CMNode

- (id)init
{
    self = [super init];
    self.childNodes = [[NSMutableArray alloc] init];
    return self;
}

- (id)initWithCode:(NSString *)code
{
    self = [self init];
    self.value = code;
    return self;
}

- (NSString *)myDescription
{
    NSMutableString* childrenString = [[NSMutableString alloc] initWithString:@"\n"];
    for (CMNode* node in self.childNodes) {
        [childrenString appendString:[node myDescription]];
        [childrenString appendString:@"\n"];
    }
    
    return [NSString stringWithFormat:@"%@ {%@}", self.value, [self.childNodes count] > 0 ? childrenString : @""];
}

@end
