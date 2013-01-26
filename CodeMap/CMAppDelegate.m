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
        
        /*NSArray* linesOfCode = [self parseLinesFromCodePart:codePart];
        for (NSMutableString* lineOfCode in linesOfCode) {
            [self parseLineOfCode:lineOfCode];
        }*/
        
        buffer = [fileHandle readDataOfLength:1024];
    }
    
    for (CMNode* node in parser.nodes) {
        NSLog(node.description);
    }
}

- (NSArray*)parseLinesFromCodePart:(NSMutableString*)codeRead
{
    NSError* error = NULL;
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@".*\\n" options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSArray* lineLocations = [regex matchesInString:codeRead options:NSMatchingProgress range:NSMakeRange(0, [codeRead length])];
    
    NSMutableArray* lines = [[NSMutableArray alloc] init];
    int lenToRemove = 0;
    for (NSTextCheckingResult* result in lineLocations) {
        NSMutableString* line = [[codeRead substringWithRange:result.range] mutableCopy];
        [lines addObject:line];
        lenToRemove += result.range.length;//this is fixed :D
    }
    
    [codeRead replaceCharactersInRange:NSMakeRange(0, lenToRemove) withString:@""];
    
    return lines;
}

- (void)parseLineOfCode:(NSMutableString*)lineOfCode
{
    NSError* error = NULL;
    NSRegularExpression* quoteFinder = [NSRegularExpression regularExpressionWithPattern:@"\\\\{0}\"" options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult* quoteSearchResult = [quoteFinder firstMatchInString:lineOfCode options:NSMatchingProgress range:NSMakeRange(0, [lineOfCode length])];
    
    while (quoteSearchResult) {
        [self addCodeNode:[lineOfCode substringToIndex:quoteSearchResult.range.location]];
        [lineOfCode replaceCharactersInRange:NSMakeRange(0, quoteSearchResult.range.location) withString:@""];
        [self removeFirstCharacter:lineOfCode];
        
        NSRange stringEndPosition = [quoteFinder firstMatchInString:lineOfCode options:NSMatchingProgress range:NSMakeRange(0, [lineOfCode length])].range;
        [self addStringNode:[lineOfCode substringToIndex:stringEndPosition.location]];
        [lineOfCode replaceCharactersInRange:NSMakeRange(0, stringEndPosition.location) withString:@""];
        [self removeFirstCharacter:lineOfCode];
        
        quoteSearchResult = [quoteFinder firstMatchInString:lineOfCode options:NSMatchingProgress range:NSMakeRange(0, [lineOfCode length])];
    }
    
    NSRange commentStart = [lineOfCode rangeOfString:@"//"];
    if (commentStart.location != NSNotFound) {
        [self addCodeNode:[lineOfCode substringToIndex:commentStart.location]];
        [self addCommentNode:[lineOfCode substringFromIndex:commentStart.location]];
    }
}

- (void)removeAllWhitespace:(NSMutableString*)code
{
    NSError* error = NULL;
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"\\s" options:NSRegularExpressionCaseInsensitive error:&error];
    [regex replaceMatchesInString:code options:NSMatchingProgress range:NSMakeRange(0, [code length]) withTemplate:@""];
}

- (void)addCodeNode:(NSString*)code
{
    [self.nodes addObject:[[CMCodeNode alloc] initWithCode:code]];
}

- (void)addStringNode:(NSString*)string
{
    [self.nodes addObject:[[CMStringNode alloc] initWithCode:string]];
}

- (void)addCommentNode:(NSString*)comment
{
    [self.nodes addObject:[[CMCommentNode alloc] initWithCode:comment]];
}

- (void)removeFirstCharacter:(NSMutableString*)string
{
    [string replaceCharactersInRange:NSMakeRange(0, 1) withString:@""];
}

@end
