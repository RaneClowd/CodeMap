//
//  CMNodeView.m
//  CodeMap
//
//  Created by Kenny Skaggs on 1/30/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import "CMNodeView.h"

@interface CMNodeView ()

@property (nonatomic, strong) NSTextView* textView;

@end

@implementation CMNodeView

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

- (CGPoint)getCenter
{
    return CGPointMake(self.frame.origin.x + self.frame.size.width/2, self.frame.origin.y + self.frame.size.height/2);
}

@end
