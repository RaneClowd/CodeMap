//
//  CMSuperView.h
//  CodeMap
//
//  Created by Kenny Skaggs on 2/25/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

@protocol CMSuperView <NSObject>

- (void)expandIfNeededToContainChild:(NSView*)child;

@end
