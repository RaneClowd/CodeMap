//
//  CMClassViewGenerator.h
//  CodeMap
//
//  Created by Kenny Skaggs on 2/22/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMPYGraphNode.h"

@interface CMClassViewGenerator : NSObject

+ (CMClassViewGenerator*)generatorForClassNamed:(NSString*)className;

- (id)initWithClassNode:(id<CMPYGraphNode>)classNode;
- (NSView*)generateAtLocation:(NSPoint)location;

@end
