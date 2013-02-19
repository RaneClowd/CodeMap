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
- (long)getHash;
- (int)getType;
- (NSString*)getText;

- (CMNodeView*)getView;
- (void)setView:(CMNodeView*)view;

@end
