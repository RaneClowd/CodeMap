//
//  CMInvocationNode.h
//  CodeMap
//
//  Created by Kenny Skaggs on 1/28/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import "CMNode.h"

@interface CMInvocationNode : CMNode

@property (nonatomic,strong) NSString* target;

- (id)initWithSelector:(NSString*)code andTarget:(NSString*)target;

@end
