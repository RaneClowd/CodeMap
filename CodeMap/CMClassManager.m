//
//  CMClassManager.m
//  CodeMap
//
//  Created by Kenny Skaggs on 2/13/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import "CMClassManager.h"

@interface CMClassManager ()

@property (nonatomic,strong) NSMutableDictionary* classNodes;

@end

@implementation CMClassManager

- (id)init
{
    self = [super init];
    self.classNodes = [[NSMutableDictionary alloc] init];
    return self;
}

- (CMClassNode *)getClassNamed:(NSString *)className
{
    CMClassNode* class = [self.classNodes objectForKey:className];
    
    if (!class) {
        class = [[CMClassNode alloc] initWithCode:className];
        [self.classNodes setObject:class forKey:className];
    }
    
    return class;
}

@end
