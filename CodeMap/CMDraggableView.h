//
//  CMDraggableView.h
//  CodeMap
//
//  Created by Kenny Skaggs on 2/4/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol DisplayDelegate <NSObject>

- (void)redraw;

@end

@interface CMDraggableView : NSView <DisplayDelegate>

@property (nonatomic,weak) id<DisplayDelegate> displayDelegate;

@end
