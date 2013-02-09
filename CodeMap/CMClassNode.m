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

@end

@implementation CMClassNode

- (id)init
{
    self = [super init];
    self.methodNodes = [[NSMutableDictionary alloc] init];
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

- (NSArray *)methods
{
    return [self.methodNodes allValues];
}

@end
