//
//  CMObjectiveCParser.m
//  CodeMap
//
//  Created by Kenny Skaggs on 1/26/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import "CMObjectiveCParser.h"
#import <ParseKit/ParseKit.h>

#import "CMCodeNode.h"
#import "CMCommentNode.h"
#import "CMStringNode.h"
#import "CMMethodNode.h"
#import "CMImportNode.h"

typedef enum {
    ParsingCommentLine,
    ParsingImport,
    ParsingMethodSignature,
    ParsingMethodBody,
    ParsingNothingSpecial
} ParsingState;

@interface CMObjectiveCParser ()

@property (nonatomic,strong) NSMutableString* rawCode;
@property (nonatomic,strong) PKParser* parser;

@property (nonatomic) ParsingState state;
@property (nonatomic) int openBracketCount;
@property (nonatomic,strong) NSMutableString* trackingValue;
@property (nonatomic,strong) CMMethodNode* openMethod;

@end

@implementation CMObjectiveCParser

- (id)init
{
    self = [super init];
    self.rawCode = [[NSMutableString alloc] init];
    self.nodes = [[NSMutableArray alloc] init];
    
    self.state = ParsingNothingSpecial;
    
    return self;
}

- (void)appendPartOfCode:(NSString*)codePart
{
    [self.rawCode appendString:codePart];
}

- (void)parseCode
{
    [self.parser parse:@"freezing cold beer."];
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

- (NSTextCheckingResult*)findFirstLocationOfPattern:(NSString*)pattern inCode:(NSString*)code
{
    NSError* error = NULL;
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    
    return [regex firstMatchInString:code options:NSMatchingProgress range:NSMakeRange(0, [code length])];
}

- (void)parseLineOfCode:(NSMutableString*)lineOfCode
{
    NSLog(@"%@", lineOfCode);
    unsigned long length = [lineOfCode length];
    
    int index = 0;
    while (index < length) {
        char current = [lineOfCode characterAtIndex:index];
        index++;
        
        switch (self.state) {
            case ParsingNothingSpecial:
                switch (current) {
                    case '/':
                        if ([lineOfCode characterAtIndex:index] == '/') {
                            index++;
                            self.state = ParsingCommentLine;
                            self.trackingValue = [[NSMutableString alloc] init];
                        }
                        break;
                        
                    case '#':
                        if ([self scanString:lineOfCode forWord:@"import" startingAtIndex:index]) {
                            index += 6;
                            self.state = ParsingImport;
                            self.trackingValue = [[NSMutableString alloc] init];
                        }
                        break;
                        
                    case '-':
                        self.state = ParsingMethodSignature;
                        self.trackingValue = [[NSMutableString alloc] init];
                        break;
                        
                    default:
                        break;
                }
                break;
                
            case ParsingCommentLine:
                if (current == '\n') {
                    self.state = ParsingNothingSpecial;
                    [self addCommentNode:self.trackingValue];
                } else {
                    [self.trackingValue appendFormat:@"%c", current];
                }
                break;
                
            case ParsingImport:
                if (current == '"' || current == '<') {
                    char importNameChar = [self consumeCharIn:lineOfCode atIndex:&index];
                    while (importNameChar != '"' && importNameChar != '>') {
                        [self.trackingValue appendFormat:@"%c", importNameChar];
                        importNameChar = [self consumeCharIn:lineOfCode atIndex:&index];
                    }
                    [self addImportNode:self.trackingValue];
                    self.state = ParsingNothingSpecial;
                }
                break;
                
            case ParsingMethodSignature:
                if (current != '{') {
                    [self.trackingValue appendFormat:@"%c", current];
                } else {
                    [self addMethodNode:self.trackingValue];
                    self.state = ParsingMethodBody;
                    self.openBracketCount = 1;
                }
                break;
                
            case ParsingMethodBody:
                if (current == '{') {
                    self.openBracketCount++;
                } else if (current == '}') {
                    self.openBracketCount--;
                }
                if (self.openBracketCount == 0) {
                    self.state = ParsingNothingSpecial;
                }
                
            default:
                break;
        }
    }
    
    /*NSTextCheckingResult* quoteSearchResult = [self findFirstLocationOfPattern:@"\\\\{0}\"" inCode:lineOfCode];
    
    while (quoteSearchResult) {
        [self addCodeNode:[lineOfCode substringToIndex:quoteSearchResult.range.location]];
        [lineOfCode replaceCharactersInRange:NSMakeRange(0, quoteSearchResult.range.location) withString:@""];
        [self removeFirstCharacter:lineOfCode];
        
        NSRange stringEndPosition = [self findFirstLocationOfPattern:@"\\\\{0}\"" inCode:lineOfCode].range;
        [self addStringNode:[lineOfCode substringToIndex:stringEndPosition.location]];
        [lineOfCode replaceCharactersInRange:NSMakeRange(0, stringEndPosition.location) withString:@""];
        [self removeFirstCharacter:lineOfCode];
        
        quoteSearchResult = [self findFirstLocationOfPattern:@"\\\\{0}\"" inCode:lineOfCode];
    }
    
    NSRange commentStart = [lineOfCode rangeOfString:@"//"];
    if (commentStart.location != NSNotFound) {
        [self addCodeNode:[lineOfCode substringToIndex:commentStart.location]];
        [self addCommentNode:[lineOfCode substringFromIndex:commentStart.location]];
    } else {
        [self addCodeNode:lineOfCode];
    }*/
}

- (char)consumeCharIn:(NSString*)string atIndex:(int*)index
{
    char nextChar = [self peekCharIn:string atIndex:index];
    *index += 1;
    return nextChar;
}

- (char)peekCharIn:(NSString*)string atIndex:(int*)index
{
    return [string characterAtIndex:*index];
}

- (BOOL)scanString:(NSString*)string forWord:(NSString*)word startingAtIndex:(NSUInteger)index
{
    /*long wordLen = [word length];
    if ([string length] - index < wordLen) {
        return NO;
    }*/
    
    return [[[string substringFromIndex:index] substringToIndex:[word length]] isEqualToString:word];
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
    if ([comment length] > 0) {
        [self.nodes addObject:[[CMCommentNode alloc] initWithCode:comment]];
    }
}

- (void)addImportNode:(NSString*)fileName
{
    [self.nodes addObject:[[CMImportNode alloc] initWithCode:fileName]];
}

- (void)addMethodNode:(NSString*)signature
{
    [self.nodes addObject:[[CMMethodNode alloc] initWithCode:signature]];
}

- (void)removeFirstCharacter:(NSMutableString*)string
{
    [string replaceCharactersInRange:NSMakeRange(0, 1) withString:@""];
}

@end
