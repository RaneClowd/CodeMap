//
//  CMClassView.h
//  CodeMap
//
//  Created by Kenny Skaggs on 2/9/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CMContainerView.h"
#import "CMPYGraphNode.h"

@interface CMClassView : CMContainerView

- (id)initWithLocation:(NSPoint)location Node:(id<CMPYGraphNode>)class;

@end
