//
//  CMInstanceNode.h
//  CodeMap
//
//  Created by Kenny Skaggs on 2/13/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import "CMValueNode.h"

@interface CMInstanceNode : CMValueNode

@property (nonatomic,strong) NSObject* classNode;

@end
