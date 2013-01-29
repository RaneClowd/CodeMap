//
//  CMNode.h
//  CodeMap
//
//  Created by Kenny Skaggs on 1/26/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMNode : NSObject

@property (nonatomic,strong) NSString* value;
@property (nonatomic,strong) NSMutableArray* childNodes;

- (id)initWithCode:(NSString*)code;
- (NSString*)description;

@end
