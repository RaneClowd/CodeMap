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
- (IBAction)inClick:(id)sender;
- (IBAction)outClick:(id)sender;

- (IBAction)mapClicked:(id)sender;
@property (strong) IBOutlet NSScrollView *scrollView;
@property (strong,nonatomic) CMMapDisplayView* displayView;

@end

@implementation CMMapViewController

- (IBAction)inClick:(id)sender
{
    CGFloat zoomFactor = 1.3;
    NSRect visible = [self.scrollView documentVisibleRect];
    NSRect newrect = NSInsetRect(visible, NSWidth(visible)*(1 - 1/zoomFactor)/2.0, NSHeight(visible)*(1 - 1/zoomFactor)/2.0);
    NSRect frame = [self.scrollView.documentView frame];
    
    [self.scrollView.documentView scaleUnitSquareToSize:NSMakeSize(zoomFactor, zoomFactor)];
    [self.scrollView.documentView setFrame:NSMakeRect(0, 0, frame.size.width * zoomFactor, frame.size.height * zoomFactor)];
    
    [[self.scrollView documentView] scrollPoint:newrect.origin];
    
    [self.displayView setNeedsDisplay:YES];
}

- (IBAction)outClick:(id)sender
{
    CGFloat zoomFactor = 1.3;
    NSRect visible = [self.scrollView documentVisibleRect];
    NSRect newrect = NSOffsetRect(visible, -NSWidth(visible)*(zoomFactor - 1)/2.0, -NSHeight(visible)*(zoomFactor - 1)/2.0);
    
    NSRect frame = [self.scrollView.documentView frame];
    
    [self.scrollView.documentView scaleUnitSquareToSize:NSMakeSize(1/zoomFactor, 1/zoomFactor)];
    [self.scrollView.documentView setFrame:NSMakeRect(0, 0, frame.size.width / zoomFactor, frame.size.height / zoomFactor)];
    
    [[self.scrollView documentView] scrollPoint:newrect.origin];
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
    
    
    self.displayView = [[CMMapDisplayView alloc] initWithFrame:CGRectMake(0, 0, 100, 100) andClasses:@[parser.openClass]];
    CGRect displayFrame = self.displayView.frame;
    [self.scrollView.documentView setFrame:CGRectMake(0, 0, displayFrame.size.width, displayFrame.size.height)];
    [self.scrollView.documentView addSubview:self.displayView];
}

@end
