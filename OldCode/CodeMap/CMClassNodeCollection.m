//
//  CMClassNodeCollection.m
//  CodeMap
//
//  Created by Kenny Skaggs on 2/26/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import "CMClassNodeCollection.h"

static NSMutableDictionary* classNodes;

@implementation CMClassNodeCollection

+ (NSMutableDictionary*)classNodeCollection
{
    if (!classNodes) {
        classNodes = [[NSMutableDictionary alloc] init];
    }
    
    return classNodes;
}

+ (id<CMPYGraphNode>)classNodeForClassName:(NSString *)className
{
    return [[self classNodeCollection] objectForKey:className];
}

+ (void)setClassNode:(id<CMPYGraphNode>)classNode forName:(NSString *)className
{
    [[self classNodeCollection] setObject:classNode forKey:className];
}

@end
