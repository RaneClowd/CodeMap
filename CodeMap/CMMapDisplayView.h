//
//  CMMapDisplayView.h
//  CodeMap
//
//  Created by Kenny Skaggs on 2/1/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CMSuperView.h"

@interface CMMapDisplayView : NSView <CMSuperView>

@property (nonatomic,strong) id<CMSuperView> myDisplayDel;

- (id)initWithFrame:(NSRect)frame andClasses:(NSArray*)classes;

@end
