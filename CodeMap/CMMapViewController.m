//
//  CMMapViewController.m
//  CodeMap
//
//  Created by Kenny Skaggs on 1/30/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import "CMMapViewController.h"
#import "CMPYObjCParser.h"
#import "CMMapDisplayView.h"
#import "CMPYGraphNode.h"
#import "CMClassViewGenerator.h"

#import "CMSuperView.h"

@interface CMMapViewController () <CMSuperView>
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
    Class parserClass = [self loadClassFromBundle];
    
    NSString * filePath = @"/Users/kennyskaggs/Projects/Utilities/CodeMap/CodeMap/CMObjectiveCParser.m";
    
    id<CMPYObjCParser> parser = [[parserClass alloc] init];
    id<CMPYGraphNode> rootNode = [parser parseFile:filePath];
    
    NSArray* classes = [rootNode getChildren];
    for (id<CMPYGraphNode> node in classes) {
        id generator = [[CMClassViewGenerator alloc] initWithClassNode:node];
        NSLog(@"generator created: %@", generator);
    }
    
    self.displayView = [[CMMapDisplayView alloc] initWithFrame:CGRectMake(0, 0, 100, 100) andClasses:classes];
    self.displayView.myDisplayDel = self;
    CGRect displayFrame = self.displayView.frame;
    [self.scrollView.documentView setFrame:CGRectMake(0, 0, displayFrame.size.width, displayFrame.size.height)];
    [self.scrollView.documentView addSubview:self.displayView];
}

- (void)expandIfNeededToContainFrame:(CGRect)frame
{
    [self.scrollView.documentView setFrame:frame];
}

- (Class)loadClassFromBundle
{
    Class parserClass;
    
    @autoreleasepool {
        NSString *pluginPath = [[NSBundle mainBundle]
                                pathForResource:@"ClangHandler"
                                ofType:@"plugin"];
        NSBundle *pluginBundle = [NSBundle bundleWithPath:pluginPath];
        [pluginBundle load];
        
        parserClass = [pluginBundle classNamed:@"ClangHandler"];
    }
    
    return parserClass;
}

@end
