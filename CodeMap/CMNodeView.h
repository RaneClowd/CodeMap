//
//  CMNodeView.h
//  CodeMap
//
//  Created by Kenny Skaggs on 1/30/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol DisplayDelegate <NSObject>

- (void)redraw;

@end

@interface CMNodeView : NSTextView

@property (nonatomic,weak) id<DisplayDelegate> displayDelegate;

- (CGPoint)getCenter;

@end
