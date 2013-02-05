//
//  CMMapViewController.m
//  CodeMap
//
//  Created by Kenny Skaggs on 1/30/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import "CMMapViewController.h"

#import "CMObjectiveCParser.h"

#import "CMMapDisplayView.h"

@interface CMMapViewController ()

- (IBAction)mapClicked:(id)sender;
@property (strong) IBOutlet NSScrollView *scrollView;

@end

@implementation CMMapViewController

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
    
    
    CMMapDisplayView* displayView = [[CMMapDisplayView alloc] initWithFrame:CGRectMake(0, 0, 100, 100) andNodes:parser.openClass.childNodes];
    CGRect displayFrame = displayView.frame;
    [self.scrollView.documentView setFrame:CGRectMake(0, 0, displayFrame.size.width, displayFrame.size.height)];
    [self.scrollView.documentView addSubview:displayView];
}

@end
