//
//  CMStack.m
//  CodeMap
//
//  Created by Kenny Skaggs on 1/28/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import "CMStack.h"

@interface CMStack ()

@property (nonatomic,strong) NSMutableArray* stack;

@end

@implementation CMStack

- (id)init
{
    self = [super init];
    self.stack = [[NSMutableArray alloc] init];
    return self;
}

- (id)peek
{
    return [self.stack lastObject];
}

- (void)push:(id)object
{
    [self.stack addObject:object];
}

- (id)pop
{
    id object = [self.stack lastObject];
    [self.stack removeLastObject];
    return object;
}

@end
