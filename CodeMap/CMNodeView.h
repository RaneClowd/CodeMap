//
//  CMNodeView.h
//  CodeMap
//
//  Created by Kenny Skaggs on 1/30/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CMDraggableView.h"

@interface CMNodeView : CMDraggableView

@property (nonatomic,weak) CMNodeView* target;
@property (nonatomic,strong) NSMutableArray* subTargeting;

@property (nonatomic,strong) NSMutableArray* listenerCollection;

- (NSPoint)connectorPoint;
- (CGFloat)relativeX;
- (CGFloat)relativeY;

+ (NSSize)approximateSizeNeededForText:(NSString*)text atFont:(NSFont*)font;

@end
