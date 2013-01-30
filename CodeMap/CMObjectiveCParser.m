//
//  CMObjectiveCParser.m
//  CodeMap
//
//  Created by Kenny Skaggs on 1/26/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import "CMObjectiveCParser.h"
#import <ParseKit/ParseKit.h>

#import "CMCommentNode.h"
#import "CMStringNode.h"
#import "CMMethodNode.h"
#import "CMImportNode.h"
#import "CMValueNode.h"
#import "CMClassNode.h"

#import "CMStack.h"

typedef enum {
    ParsingCommentLine,
    ParsingImport,
    ParsingMethodSignature,
    ParsingMethodBody,
    ParsingString,
    ParsingChar,
    ParsingInvocationTarget,
    ParsingInvocationSelector,
    ParsingIgnoringWhitespace,
    ParsingNothingSpecial
} ParsingState;

@interface CMObjectiveCParser ()

@property (nonatomic,strong) NSMutableString* rawCode;
@property (nonatomic,strong) PKParser* parser;

@property (nonatomic,strong) CMStack* stateStack;
@property (nonatomic,strong) CMStack* nodeStack;

@property (nonatomic) int openBracketCount;
@property (nonatomic,strong) NSMutableString* trackingValue;

@end

@implementation CMObjectiveCParser

- (id)init
{
    self = [super init];
    self.rawCode = [[NSMutableString alloc] init];
    self.nodes = [[NSMutableArray alloc] init];
    
    self.stateStack = [[CMStack alloc] init];
    [self enterState:ParsingNothingSpecial];
    
    self.nodeStack = [[CMStack alloc] init];
    CMClassNode* class = [[CMClassNode alloc] init];
    
    
    return self;
}

- (void)appendPartOfCode:(NSString*)codePart
{
    [self.rawCode appendString:codePart];
}

- (void)parseCode
{
    [self.parser parse:@"freezing cold { beer."];
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
    //NSLog(@"%@", lineOfCode);
    
    //does the machine handle wrenches? }
    
    unsigned long length = [lineOfCode length];
    
    int index = 0;
    while (index < length) {
        char current = [self consumeCharIn:lineOfCode atIndex:&index];
        
        if ([self getState] == ParsingIgnoringWhitespace)
        {
            if (![self charIsWhitespace:current]) {
                [self leaveCurrentState];
            }
        }
        
        switch ([self getState]) {
            case ParsingNothingSpecial:
                switch (current) {
                    case '/':
                        if ([self scanString:lineOfCode forWord:@"/" startingAtIndex:&index]) {
                            [self enterState:ParsingCommentLine];
                            self.trackingValue = [[NSMutableString alloc] init];
                        }
                        break;
                        
                    case '#':
                        if ([self scanString:lineOfCode forWord:@"import" startingAtIndex:&index]) {
                            [self enterState:ParsingImport];
                            self.trackingValue = [[NSMutableString alloc] init];
                        }
                        break;
                        
                    case '-':
                        [self enterState:ParsingMethodSignature];
                        self.trackingValue = [[NSMutableString alloc] init];
                        break;
                        
                    default:
                        break;
                }
                break;
                
            case ParsingCommentLine:
                if (current == '\n') {
                    [self leaveCurrentState];
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
                    [self leaveCurrentState];
                }
                break;
                
            case ParsingMethodSignature:
                if (current != '{') {
                    [self.trackingValue appendFormat:@"%c", current];
                } else {
                    [self definingMethodWithSignature:self.trackingValue];
                    [self leaveCurrentState];
                    [self enterState:ParsingMethodBody];
                    self.openBracketCount = 1;
                }
                break;
                
            case ParsingString:
                if (current == '"') {
                    [self leaveCurrentState];
                } else if (current == '\\') {
                    [self consumeCharIn:lineOfCode atIndex:&index];
                }
                break;
                
            case ParsingChar:
                if (current == '\'') {
                    [self leaveCurrentState];
                } else if (current == '\\') {
                    [self consumeCharIn:lineOfCode atIndex:&index];
                }
                break;
                
            case ParsingInvocationTarget:
                if (current == '[') {
                    [self beginDefiningInvocation];
                } else if (![self charIsWhitespace:current]) {
                    [self.trackingValue appendFormat:@"%c", current];
                } else {
                    [self leaveCurrentState];
                    [self setValueForOpenNode:self.trackingValue];
                    [self closeNode];
                    
                    self.trackingValue = [[NSMutableString alloc] init];
                    [self enterState:ParsingInvocationSelector];
                    [self enterState:ParsingIgnoringWhitespace];
                }
                break;
                
            case ParsingInvocationSelector:
                if (current == ']') {
                    [self leaveCurrentState];
                    [self setValueForOpenNode:self.trackingValue];
                    [self closeNode];
                } else {
                    [self.trackingValue appendFormat:@"%c", current];
                }
                break;
                
            case ParsingMethodBody:
                switch (current) {
                    case '{':
                        self.openBracketCount++;
                        break;
                        
                    case '"':
                        [self enterState:ParsingString];
                        break;
                        
                    case '\'':
                        [self enterState:ParsingChar];
                        break;
                        
                    case '/':
                        if ([self scanString:lineOfCode forWord:@"/" startingAtIndex:&index]) {
                            [self enterState:ParsingCommentLine];
                            self.trackingValue = [[NSMutableString alloc] init];
                        }
                        break;
                        
                    case '[':
                        self.trackingValue = [[NSMutableString alloc] init];
                        [self beginDefiningInvocation];
                        break;
                        
                    case '}':
                        self.openBracketCount--;
                        break;
                        
                    default:
                        break;
                }
                
                if (self.openBracketCount == 0) {
                    [self leaveCurrentState];
                    [self closeNode];
                }
                
            default:
                break;
        }
    }
}

- (BOOL)charIsWhitespace:(char)character
{
    return [[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:character];
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

- (BOOL)scanString:(NSString*)string forWord:(NSString*)word startingAtIndex:(int*)index
{
    long len = [word length];
    BOOL exists = [[[string substringFromIndex:*index] substringToIndex:len] isEqualToString:word];
    if (exists) *index += len;
    return exists;
}

- (NSString*)trimWhiteSpaceFrom:(NSString*)string
{
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

#pragma mark - Node Management

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

- (void)definingMethodWithSignature:(NSString*)signature
{
    CMMethodNode* methodNode = [[CMMethodNode alloc] initWithCode:[self trimWhiteSpaceFrom:signature]];
    [self.nodes addObject:methodNode];
    [self enterNode:methodNode];
}

- (void)beginDefiningInvocation
{
    CMInvocationNode* invocationNode = [[CMInvocationNode alloc] init];
    CMValueNode* targetNode = [[CMValueNode alloc] init];
    CMValueNode* selectorNode = [[CMValueNode alloc] init];
    
    invocationNode.target = targetNode;
    invocationNode.selector = selectorNode;
    
    CMNode* parentNode = [self getCurrentNode];
    [parentNode.childNodes addObject:invocationNode];
    
    [self enterNode:selectorNode];
    [self enterNode:targetNode];
    
    [self enterState:ParsingInvocationTarget];
    [self enterState:ParsingIgnoringWhitespace];
}

- (void)setValueForOpenNode:(NSString*)value
{
    CMNode* node = [self getCurrentNode];
    node.value = value;
}

- (void)definingInvocationSelector:(NSString*)selector
{
    CMInvocationNode* invocationNode = (CMInvocationNode*)[self getCurrentNode];
    invocationNode.value = selector;
}

#pragma mark - Stack Handling

#pragma mark Nodes

- (CMNode*)getCurrentNode
{
    return [self.nodeStack peek];
}

- (void)enterNode:(CMNode*)node
{
    [self.nodeStack push:node];
}

- (void)closeNode
{
    [self.nodeStack pop];
}

#pragma mark Parser State

- (ParsingState)getState
{
    return [[self.stateStack peek] intValue];
}

- (void)enterState:(ParsingState)state
{
    [self.stateStack push:[NSNumber numberWithInt:state]];
}

- (void)leaveCurrentState
{
    [self.stateStack pop];
}

@end
