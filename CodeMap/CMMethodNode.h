//
//  CMMethodNode.h
//  CodeMap
//
//  Created by Kenny Skaggs on 1/26/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMNode.h"
#import "CMInvocationNode.h"

@interface CMMethodNode : CMNode

- (void)addInvocationNode:(CMInvocationNode*)invocation;

@end
