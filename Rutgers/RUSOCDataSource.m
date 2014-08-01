//
//  RUSOCDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/24/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUSOCDataSource.h"
#import "RUSOCDataLoadingManager.h"
#import "DataTuple.h"
#import "ALTableViewTextCell.h"

@implementation RUSOCDataSource

-(id)init{
    self = [super init];
    if (self) {
        self.title = @"Subjects";
    }
    return self;
}

-(void)loadContent{
    [self loadContentWithBlock:^(AAPLLoading *loading) {
        [[RUSOCDataLoadingManager sharedInstance] getSubjectsWithSuccess:^(NSArray *subjects) {
            [loading updateWithContent:^(typeof(self) me) {
                [me parseResponse:subjects];
            }];
        } failure:^{
            [loading doneWithError:nil];
        }];
    }];
}

-(void)parseResponse:(NSArray *)response{
    NSMutableArray *subjects = [NSMutableArray array];
    
    for (NSDictionary *subject in response) {
        NSString *subjectTitle = [NSString stringWithFormat:@"%@ (%@)",[subject[@"description"] capitalizedString],subject[@"code"]];
        
        [subjects addObject:[DataTuple tupleWithTitle:subjectTitle object:subject]];
    }
    
    self.items = subjects;
}


-(NSString *)reuseIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath{
    return NSStringFromClass([ALTableViewTextCell class]);
}

-(void)configureCell:(ALTableViewTextCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    DataTuple *tuple = [self itemAtIndexPath:indexPath];
    cell.textLabel.text = tuple.title;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

@end
