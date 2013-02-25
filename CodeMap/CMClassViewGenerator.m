//
//  CMClassViewGenerator.m
//  CodeMap
//
//  Created by Kenny Skaggs on 2/22/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import "CMClassViewGenerator.h"
#import "CMClassView.h"

@interface CMClassViewGenerator ()

@property (nonatomic,strong) id<CMPYGraphNode> classNode;

@end

@implementation CMClassViewGenerator

static NSMutableDictionary* classGenerators;

+ (CMClassViewGenerator *)generatorForClassNamed:(NSString *)className
{
    return [[CMClassViewGenerator generators] objectForKey:className];
}

+ (NSMutableDictionary*)generators
{
    if (!classGenerators) {
        classGenerators = [[NSMutableDictionary alloc] init];
    }
    return classGenerators;
}

- (id)initWithClassNode:(id<CMPYGraphNode>)classNode
{
    self = [super init];
    self.classNode = classNode;
    [[CMClassViewGenerator generators] setObject:self forKey:[classNode getText]];
    return self;
}

- (NSView *)generateAtLocation:(NSPoint)location
{
    return [[CMClassView alloc] initWithNode:self.classNode andLocation:location];
}

@end
