//
//  CMObjectiveCParser.h
//  CodeMap
//
//  Created by Kenny Skaggs on 1/26/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMObjectiveCParser : NSObject

@property (nonatomic,strong) NSMutableArray* nodes;

- (void)parseCodePart:(NSString*)codePart;

@end
