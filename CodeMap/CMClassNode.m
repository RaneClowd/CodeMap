//
//  CMClassNode.m
//  CodeMap
//
//  Created by Kenny Skaggs on 1/28/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import "CMClassNode.h"

@implementation CMClassNode

- (CMNode *)nodeForName:(NSString *)name
{
    if ([name isEqualToString:@"self"]) return self;
    else return [super nodeForName:name];
}

@end
