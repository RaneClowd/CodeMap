//
//  CMPYGraphNode.h
//  CodeMap
//
//  Created by Kenny Skaggs on 2/18/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMNodeView.h"

@protocol CMPYGraphNode <NSObject>

- (NSArray*)getChildren;
- (id<CMPYGraphNode>)getParent;

- (CMNodeView*)getView;
- (void)setView:(CMNodeView*)view;

- (NSArray*)getTargets;

- (id)getHash;
- (id<CMPYGraphNode>)getObjectForKey:(id)key;
- (NSString*)getTargetingKey;

- (NSString*)getType;
- (NSString*)getText;

- (NSString*)getPubliclyAccessible;

@end
