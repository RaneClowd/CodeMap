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
#import "CMNodeView.h"

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
    
    CGFloat topY = 800;
    CGFloat x = 100;
    
    [self.scrollView.documentView setAutoresizesSubviews:NO];
    
    for (CMNode* node in parser.nodes) {
        CGFloat y = 100;
        
        CMNodeView* nodeLabel = [self createLabelWithFrame:CGRectMake(x, y, 100, 30)];
        [nodeLabel setString:[node myDescription]];
        [self.scrollView.documentView addSubview:nodeLabel];
        
        for (CMNode* childNode in [node childNodes]) {
            CMNodeView* nodeLabel = [self createLabelWithFrame:CGRectMake(x, y, 100, 30)];
            [nodeLabel setString:[childNode myDescription]];
            [self.scrollView.documentView addSubview:nodeLabel];
            
            y += 50;
        }
        
        x += 110;
     }
    
    [self.scrollView.documentView setFrame:CGRectMake(0, 0, x+150, topY+100)];
}

- (CMNodeView*)createLabelWithFrame:(CGRect)frame
{
    CMNodeView* label = [[CMNodeView alloc] initWithFrame:frame];
    return label;
}

@end
