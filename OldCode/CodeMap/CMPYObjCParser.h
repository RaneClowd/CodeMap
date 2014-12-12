//
//  CMPYObjCParser.h
//  CodeMap
//
//  Created by Kenny Skaggs on 2/18/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CMPYObjCParser <NSObject>

- (id)parseFile:(NSString*)filePath;

@end
