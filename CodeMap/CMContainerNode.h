//
//  CMContainerNode.h
//  CodeMap
//
//  Created by Kenny Skaggs on 1/29/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import "CMNode.h"

@interface CMContainerNode : CMNode

- (void)addItemToContext:(NSString*)name forNode:(CMNode*)node;
- (CMNode*)nodeForName:(NSString*)name;

@end
