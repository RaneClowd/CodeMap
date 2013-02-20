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

- (id<CMPYGraphNode>)getTarget;
- (void)setTarget:(id<CMPYGraphNode>)target;

- (id)getHash;
- (id<CMPYGraphNode>)getObjectForKey:(id)key;

- (NSString*)getType;
- (NSString*)getText;

- (CMNodeView*)getView;
- (void)setView:(CMNodeView*)view;

@end
