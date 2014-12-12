//
//  CMClassNodeCollection.h
//  CodeMap
//
//  Created by Kenny Skaggs on 2/26/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CMPYGraphNode.h"

@interface CMClassNodeCollection : NSObject

+ (id<CMPYGraphNode>)classNodeForClassName:(NSString*)className;
+ (void)setClassNode:(id<CMPYGraphNode>)classNode forName:(NSString*)className;

@end
