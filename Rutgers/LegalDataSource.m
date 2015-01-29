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
        
        for (NSURL *legalNoticeURL in contents) {
            NSData *data = [NSData dataWithContentsOfURL:legalNoticeURL];
            NSString *text;
            [NSString stringEncodingForData:data encodingOptions:nil convertedString:&text usedLossyConversion:nil];
            if (text) {
                StringDataSource *dataSource = [[StringDataSource alloc] initWithItems:@[text]];
                dataSource.title = [[legalNoticeURL lastPathComponent] stringByDeletingPathExtension];
                [self addDataSource:dataSource];
            }
        }
    }
    return self;
}
@end
