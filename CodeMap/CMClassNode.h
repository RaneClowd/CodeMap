//
//  CMClassNode.h
//  CodeMap
//
//  Created by Kenny Skaggs on 1/28/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import "CMNode.h"
#import "CMMethodNode.h"

@interface CMClassNode : CMNode

- (CMMethodNode*)methodForSignature:(NSString*)signature;
- (NSArray*)methods;

@end
