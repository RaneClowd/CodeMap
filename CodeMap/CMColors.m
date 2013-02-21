//
//  CMColors.m
//  CodeMap
//
//  Created by Kenny Skaggs on 2/19/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import "CMColors.h"

@implementation CMColors

+ (NSColor *)implementatedColor
{
    return [NSColor colorWithCalibratedRed:0.3203 green:0.6023 blue:0.7773 alpha:1];
}

+ (NSColor *)interfacedColor
{
    return [NSColor colorWithCalibratedRed:0.6203 green:0.4023 blue:0.4773 alpha:1];
}

+ (NSColor *)privateMethod
{
    return [NSColor colorWithCalibratedRed:0.3203 green:0.4023 blue:0.7773 alpha:1];
}

+ (NSColor *)publicMethod
{
    return [NSColor colorWithCalibratedRed:0.2203 green:0.6023 blue:0.4773 alpha:1];
}

@end
