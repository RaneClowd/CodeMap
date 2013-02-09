//
//  CMClassView.h
//  CodeMap
//
//  Created by Kenny Skaggs on 2/9/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CMNodeView.h"
#import "CMClassNode.h"

@interface CMClassView : CMNodeView

- (id)initWithLocation:(NSPoint)location Node:(CMClassNode*)class;

@end
