//
//  CMMethod.h
//  CodeMap
//
//  Created by Kenny Skaggs on 2/2/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CMContainerView.h"
#import "CMPYGraphNode.h"

@interface CMMethodView : CMContainerView

- (id)initWithLocation:(NSPoint)location andNode:(id<CMPYGraphNode>)node;

@end
