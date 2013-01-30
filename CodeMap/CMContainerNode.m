//
//  CMContainerNode.m
//  CodeMap
//
//  Created by Kenny Skaggs on 1/29/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import "CMContainerNode.h"

@interface CMContainerNode ()

@property (nonatomic,strong) NSMutableDictionary* context;

@end

@implementation CMContainerNode

- (void)addItemToContext:(NSString *)name forNode:(CMNode *)node
{
    [self.context setObject:node forKey:name];
}

- (CMNode *)nodeForName:(NSString *)name
{
    return [self.context objectForKey:name];
}

@end
