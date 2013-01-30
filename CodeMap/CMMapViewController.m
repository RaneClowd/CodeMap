//
//  CMMapViewController.m
//  CodeMap
//
//  Created by Kenny Skaggs on 1/30/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import "CMMapViewController.h"

#import "CMObjectiveCParser.h"
#import "CMNode.h"

@interface CMMapViewController ()

- (IBAction)mapClicked:(id)sender;
@property (strong) IBOutlet NSScrollView *scrollView;

@end

@implementation CMMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (IBAction)mapClicked:(id)sender
{
    CMObjectiveCParser* parser = [[CMObjectiveCParser alloc] init];
    
    NSString * path = @"/Users/kennyskaggs/Projects/Utilities/CodeMap/CodeMap/CMObjectiveCParser.m";
    NSFileHandle * fileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
    
    NSData * buffer = [fileHandle readDataOfLength:1024];
    while ([buffer length] > 0) { // this is cool
        [parser parseCodePart:[[NSMutableString alloc] initWithData:buffer encoding:NSUTF8StringEncoding]];
        
        buffer = [fileHandle readDataOfLength:1024];
    }
    
    CGFloat topY = 0;
    
    CGFloat x = 0;
    for (CMNode* node in parser.nodes) {
        CGFloat y = 0;
        
        for (CMNode* childNode in [node childNodes]) {
            y += 100;
            if (topY < y) topY = y;
        }
        
        x += 150;
    }
    
    [self.scrollView.documentView setFrame:CGRectMake(0, 0, x+150, topY+100)];
    
    x = 0;
    for (CMNode* node in parser.nodes) {
        CGFloat y = 0;
        
        NSTextView* nodeLabel = [self createLabelWithFrame:CGRectMake(x, y, 100, 30)];
        [nodeLabel setString:[node myDescription]];
        [self.scrollView addSubview:nodeLabel];
        
        for (CMNode* childNode in [node childNodes]) {
            NSTextView* nodeLabel = [self createLabelWithFrame:CGRectMake(x, y, 100, 30)];
            [nodeLabel setString:[node myDescription]];
            [self.scrollView addSubview:nodeLabel];
            
            y += 100;
        }
        
        x += 150;
    }
}

- (NSTextView*)createLabelWithFrame:(CGRect)frame
{
    NSTextView* label = [[NSTextView alloc] initWithFrame:frame];
    [label setEditable:NO];
    [label setSelectable:NO];
    [label setAutoresizesSubviews:NO];
    return label;
}

@end
