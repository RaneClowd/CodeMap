//
//  CMObjectiveCParser.m
//  CodeMap
//
//  Created by Kenny Skaggs on 1/26/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import "CMObjectiveCParser.h"

#import "CMCodeNode.h"
#import "CMCommentNode.h"
#import "CMStringNode.h"

@interface CMObjectiveCParser ()

@property (nonatomic,strong) NSMutableString* rawCode;

@end

@implementation CMObjectiveCParser

- (id)init
{
    self = [super init];
    self.rawCode = [[NSMutableString alloc] init];
    self.nodes = [[NSMutableArray alloc] init];
    return self;
}

- (void)parseCodePart:(NSString *)codePart
{
    [self.rawCode appendString:codePart];
    
    NSArray* codeLines = [self extractLines:self.rawCode];
    
    for (NSMutableString* codeLine in codeLines) {
        [self parseLineOfCode:codeLine];
    }
}

- (NSArray*)extractLines:(NSMutableString*)rawCode
{
    NSArray* lineLocations = [self findLocationsOfPattern:@".*\\n" inCode:rawCode];
    
    NSMutableArray* lines = [[NSMutableArray alloc] init];
    int lenToRemove = 0;
    for (NSTextCheckingResult* result in lineLocations) {
        NSMutableString* line = [[rawCode substringWithRange:result.range] mutableCopy];
        [lines addObject:line];
        lenToRemove += result.range.length;//this is fixed :D
    }
    
    [self clearString:rawCode beforePosition:lenToRemove];
    
    return lines;
}

- (void)clearString:(NSMutableString*)string beforePosition:(int)position
{
    [string replaceCharactersInRange:NSMakeRange(0, position) withString:@""];
}

- (NSArray*)findLocationsOfPattern:(NSString*)pattern inCode:(NSString*)code
{
    NSError* error = NULL;
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    
    return [regex matchesInString:code options:NSMatchingProgress range:NSMakeRange(0, [code length])];
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
