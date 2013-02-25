//
//  CMContainerView.h
//  CodeMap
//
//  Created by Kenny Skaggs on 2/13/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import "CMNodeView.h"
#import "CMSuperView.h"

@interface CMContainerView : CMNodeView

@property (nonatomic,strong) NSTextView* titleView;

@property (nonatomic) NSRect secondaryDotRect;

@property (nonatomic) BOOL collapsed;
@property (nonatomic) NSSize sizeBeforeCollapse;

- (id)initWithLocation:(NSPoint)location size:(int)size andTitle:(NSString *)title;
- (NSPoint)secondaryConnectorPoint;
- (void)toggleCollapsed;

@end
