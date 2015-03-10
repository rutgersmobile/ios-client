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
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *legalURL = [[[NSBundle mainBundle] bundleURL] URLByAppendingPathComponent:@"legal" isDirectory:YES];
        NSArray *contents = [fileManager contentsOfDirectoryAtURL:legalURL includingPropertiesForKeys:@[] options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
        
        //Make a seperate section for each file in the legal folder
        for (NSURL *legalNoticeURL in contents) {
            NSData *data = [NSData dataWithContentsOfURL:legalNoticeURL];
            NSString *text;
            [NSString stringEncodingForData:data encodingOptions:nil convertedString:&text usedLossyConversion:nil];
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
    [string enumerateSubstringsInRange:NSMakeRange(0, string.length) options:NSStringEnumerationByLines usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        substring = [substring stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([substring isEqualToString:@""]) {
            [processedString appendString:@"\n\n"];
            newLine  = YES;
        } else {
            if (newLine) {
                [processedString appendString:substring];
            } else {
                if ([substring substringToIndex:1].integerValue) {
                    [processedString appendFormat:@"\n%@",substring];
                } else {
                    [processedString appendFormat:@" %@",substring];
                }
            }
            newLine = NO;
        }
    }];
    return processedString;
}
@end
