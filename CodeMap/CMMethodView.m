//
//  CMMethod.m
//  CodeMap
//
//  Created by Kenny Skaggs on 2/2/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import "CMMethodView.h"

@interface CMMethodView ()

@property (nonatomic, strong) NSTextView* signatureView;

@end

@implementation CMMethodView

- (id)initWithFrame:(NSRect)frame andSignature:(NSString*)signature
{
    self = [super initWithFrame:frame];
    
    self.signatureView = [[NSTextView alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    [self.signatureView setEditable:NO];
    [self.signatureView setSelectable:NO];
    [self.signatureView setString:signature];
    [self addSubview:self.signatureView];
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    //[[NSColor blackColor] setFill];
    //NSRectFill(dirtyRect);
    
    //[self.signatureView setNeedsDisplay:YES];
}

@end
