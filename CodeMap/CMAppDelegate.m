//
//  CMAppDelegate.m
//  CodeMap
//
//  Created by Kenny Skaggs on 1/25/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import "CMAppDelegate.h"
#import "CMCodeNode.h"
#import "CMStringNode.h"
#import "CMCommentNode.h"

#import "CMObjectiveCParser.h"

@interface CMAppDelegate ()

@property (nonatomic,strong) NSMutableArray* nodes;

@end

@implementation CMAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSString* test = @"// this is no comment";
    // Insert code here to initialize your application
    
    self.nodes = [[NSMutableArray alloc] init];
}

- (IBAction)mapClicked:(id)sender
{
    CMObjectiveCParser* parser = [[CMObjectiveCParser alloc] init];
    
    NSString * path = @"/Users/kennyskaggs/Projects/Utilities/CodeMap/CodeMap/CMAppDelegate.m";
    NSFileHandle * fileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
    
    NSData * buffer = [fileHandle readDataOfLength:1024];
    while ([buffer length] > 0) { // this is cool
        
        [parser parseCodePart:[[NSMutableString alloc] initWithData:buffer encoding:NSUTF8StringEncoding]];
        
        //[parser appendPartOfCode:[[NSMutableString alloc] initWithData:buffer encoding:NSUTF8StringEncoding]];
        
        /*NSArray* linesOfCode = [self parseLinesFromCodePart:codePart];
        for (NSMutableString* lineOfCode in linesOfCode) {
            [self parseLineOfCode:lineOfCode];
        }*/
        
        buffer = [fileHandle readDataOfLength:1024];
    }
    
    //[parser parseCode];
    
    for (CMNode* node in parser.nodes) {
        NSLog([node description]);
    }
}

@end
