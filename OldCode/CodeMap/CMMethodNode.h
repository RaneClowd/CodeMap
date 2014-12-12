//
//  CMMethodNode.h
//  CodeMap
//
//  Created by Kenny Skaggs on 1/26/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMInvocationNode.h"

@interface CMMethodNode : CMNode

@property (nonatomic,strong) CMNode* firstExecutionNode;
@property (nonatomic,strong) CMNode* lastExecutionNode;

- (void)addNodeOfExecution:(CMNode*)node;

@end
