//
//  CMValueView.m
//  CodeMap
//
//  Created by Kenny Skaggs on 2/5/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import "CMValueView.h"

@interface CMValueView ()

@property (nonatomic, strong) NSTextView* textView;

@end

@implementation CMValueView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    
    self.textView = [[NSTextView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    [self.textView setEditable:NO];
    [self.textView setSelectable:NO];
    [self addSubview:self.textView];
    
    return self;
}

- (void)setString:(NSString *)text
{
    [self.textView setString:text];
}

@end
