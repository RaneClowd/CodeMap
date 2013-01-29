//
//  CMStack.h
//  CodeMap
//
//  Created by Kenny Skaggs on 1/28/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMStack : NSObject

- (void)push:(id)object;
- (id)pop;
- (id)peek;

@end
