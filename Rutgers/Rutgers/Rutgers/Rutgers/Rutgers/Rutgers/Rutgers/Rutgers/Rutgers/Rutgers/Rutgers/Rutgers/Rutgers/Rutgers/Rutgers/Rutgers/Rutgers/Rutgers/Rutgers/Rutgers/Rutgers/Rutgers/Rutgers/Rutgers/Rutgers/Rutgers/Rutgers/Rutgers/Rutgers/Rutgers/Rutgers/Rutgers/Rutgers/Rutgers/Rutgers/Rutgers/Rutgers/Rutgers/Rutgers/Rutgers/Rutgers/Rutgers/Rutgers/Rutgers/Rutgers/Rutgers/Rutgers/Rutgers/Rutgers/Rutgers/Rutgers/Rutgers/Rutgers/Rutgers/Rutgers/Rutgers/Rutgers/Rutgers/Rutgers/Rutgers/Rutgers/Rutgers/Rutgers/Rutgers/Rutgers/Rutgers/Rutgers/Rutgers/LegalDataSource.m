//
//  RULegalDataSource.m
//  Rutgers
//
//  Created by Open Systems Solutions on 1/28/15.
//  Copyright (c) 2015 Rutgers. All rights reserved.
//

#import "LegalDataSource.h"
#import "StringDataSource.h"

@implementation LegalDataSource

-(instancetype)init{
    self = [super init];
    if (self) {
        //Find all the contents of the legal folder
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *legalURL = [[[NSBundle mainBundle] bundleURL] URLByAppendingPathComponent:@"legal" isDirectory:YES];
        NSArray *contents = [fileManager contentsOfDirectoryAtURL:legalURL includingPropertiesForKeys:@[] options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
        
        //Make a seperate section for each file in the legal folder
        for (NSURL *legalNoticeURL in contents) {
            NSData *data = [NSData dataWithContentsOfURL:legalNoticeURL];
            NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if (text) {
                StringDataSource *dataSource = [[StringDataSource alloc] initWithItems:@[[self processLegalText:text]]];
                dataSource.title = [[legalNoticeURL lastPathComponent] stringByDeletingPathExtension];
                [self addDataSource:dataSource];
            }
        }
    }
    return self;
}

/**
 *  Algorithm for removing excess line breaks in legal text files
 *
 *  @param string The contents of a legal text file
 *
 *  @return The contents with line breaks removed.
 */
-(NSString *)processLegalText:(NSString *)string{
    NSMutableString *processedString = [NSMutableString string];
    
    __block BOOL newLine = YES;
    //Enumerate string line by line, building a new string with the proper content and line breaks
    [string enumerateSubstringsInRange:NSMakeRange(0, string.length) options:NSStringEnumerationByLines usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        substring = [substring stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([substring isEqualToString:@""]) {
            //If this was an empty line
            //Add two line breaks
            [processedString appendString:@"\n\n"];
            newLine = YES;
        } else {
            //We have some content on this line
            if (newLine) {
                //If this is a new line, just append the content
                [processedString appendString:substring];
            } else {
                //If not on a new line, check if this is a bullet point
                if ([substring substringToIndex:1].integerValue) {
                    //If yes, append the content on a newline
                    [processedString appendFormat:@"\n%@",substring];
                } else {
                    //If no, append the content after a space
                    [processedString appendFormat:@" %@",substring];
                }
            }
            newLine = NO;
        }
    }];
    return processedString;
}
@end
