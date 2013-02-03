//
//  CMClassNode.m
//  CodeMap
//
//  Created by Kenny Skaggs on 1/28/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import "CMClassNode.h"

@interface CMClassNode ()

@property (nonatomic,strong) NSMutableDictionary* methods;

@end

@implementation CMClassNode

- (id)init
{
    self = [super init];
    self.methods = [[NSMutableDictionary alloc] init];
    return self;
}

- (CMMethodNode *)methodForSignature:(NSString *)signature
{
    CMMethodNode* method = [self.methods objectForKey:signature];
    
    if (!method) {
        method = [[CMMethodNode alloc] initWithCode:signature];
        [self.methods setObject:method forKey:signature];
        
        [self.childNodes addObject:method];
        method.parentNode = self;
    }
    
    return method;
}

@end
