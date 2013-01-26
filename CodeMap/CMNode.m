//
//  CMNode.m
//  CodeMap
//
//  Created by Kenny Skaggs on 1/26/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import "CMNode.h"

@implementation CMNode

- (id)initWithCode:(NSString *)code
{
    self = [super init];
    self.value = code;
    return self;
}

@end
