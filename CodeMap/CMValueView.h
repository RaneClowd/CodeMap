//
//  CMValueView.h
//  CodeMap
//
//  Created by Kenny Skaggs on 2/5/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import "CMNodeView.h"
#import "CMNode.h"

@interface CMValueView : CMNodeView

- (id)initWithFrame:(NSRect)frame andNode:(CMNode*)node;
- (CGFloat)widthNeeded;

@end
