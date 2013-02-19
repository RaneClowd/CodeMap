//
//  CMClassNode.m
//  CodeMap
//
//  Created by Kenny Skaggs on 1/28/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import "CMClassNode.h"

@interface CMClassNode ()

@property (nonatomic,strong) NSMutableDictionary* methodNodes;
@property (nonatomic,strong) NSMutableDictionary* propertyNodes;

@end

@implementation CMClassNode

- (id)init
{
    self = [super init];
    self.methodNodes = [[NSMutableDictionary alloc] init];
    self.propertyNodes = [[NSMutableDictionary alloc] init];
    return self;
}

- (CMMethodNode *)methodForSignature:(NSString *)signature
{
    CMMethodNode* method = [self.methodNodes objectForKey:signature];
    
    if (!method) {
        method = [[CMMethodNode alloc] initWithCode:signature];
        [self.methodNodes setObject:method forKey:signature];
        
        method.parentNode = self;
    }
    
    return method;
}

- (CMInstanceNode *)propertyByName:(NSString *)propertyName
{
    CMInstanceNode* property = [self.propertyNodes objectForKey:propertyName];
    
    if (!property) {
        property = [[CMInstanceNode alloc] initWithCode:propertyName];
        [self.propertyNodes setObject:property forKey:propertyName];
        
        property.parentNode = self;
    }
    
    return property;
}

- (NSArray *)methods
{
    return [self.methodNodes allValues];
}

@end
