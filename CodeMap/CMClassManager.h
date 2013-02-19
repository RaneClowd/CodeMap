//
//  CMClassManager.h
//  CodeMap
//
//  Created by Kenny Skaggs on 2/13/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CMClassNode.h"

@interface CMClassManager : NSObject

- (CMClassNode*)getClassNamed:(NSString*)className;

@end
