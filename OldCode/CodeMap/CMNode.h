//
//  CMNode.h
//  CodeMap
//
//  Created by Kenny Skaggs on 1/26/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMNodeView.h"

@interface CMNode : NSObject

@property (nonatomic,strong) NSString* value;

@property (nonatomic,weak) CMNode* parentNode;
@property (nonatomic,strong) NSMutableArray* childNodes;

@property (nonatomic,strong) CMNode* nextInLine;

@property (nonatomic,strong) CMNodeView* nodeView;

- (id)initWithCode:(NSString*)code;

- (NSString*)myDescription;

@end
