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
#import "TupleDataSource.h"
#import "ALTableViewTextCell.h"

@interface RUSOCDataSource ()
@property (nonatomic) NSArray *sectionIndexTitles;
@end

@implementation RUSOCDataSource

-(instancetype)init{
    self = [super init];
    if (self) {
        self.title = @"Subjects";
    }
    return self;
}

-(void)setItems:(NSArray *)items{
    NSMutableDictionary *sectionIndexMapping = [NSMutableDictionary dictionary];
    for (DataTuple *item in items) {
        NSString *letter = [[item.title substringToIndex:1] capitalizedString];
        NSMutableArray *section = sectionIndexMapping[letter];
        if (!section) {
            section = [NSMutableArray array];
            sectionIndexMapping[letter] = section;
        }
        [section addObject:item];
    }
    
    NSArray *sectionIndexTitles = [sectionIndexMapping.allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    _sectionIndexTitles = sectionIndexTitles;
  
    [self removeAllDataSources];

    for (NSString *letter in sectionIndexTitles) {
        [self addDataSource:[[TupleDataSource alloc] initWithItems:sectionIndexMapping[letter]]];
    }
}

-(void)registerReusableViewsWithTableView:(UITableView *)tableView{
    [super registerReusableViewsWithTableView:tableView];
    [tableView registerClass:[ALTableViewTextCell class] forCellReuseIdentifier:NSStringFromClass([ALTableViewTextCell class])];
}

-(NSString *)reuseIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath{
    return NSStringFromClass([ALTableViewTextCell class]);
}

-(NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    return self.sectionIndexTitles;
}

-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    return index;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return self.sectionIndexTitles[section];
}

-(void)loadContent{
    [self removeAllDataSources];

    [self loadContentWithBlock:^(AAPLLoading *loading) {
        [[RUSOCDataLoadingManager sharedInstance] getSubjectsWithCompletion:^(NSArray *subjects, NSError *error) {
            if (!loading.current) {
                [loading ignore];
                return;
            }
            
            if (!error) {
                NSArray *parsedSubjects = [self parseResponse:subjects];
                [loading updateWithContent:^(typeof(self) me) {
                    me.items = parsedSubjects;
                }];
            } else {
                [loading doneWithError:error];
            }
        }];
    }];
}

-(NSArray *)parseResponse:(NSArray *)response{
    NSMutableArray *subjects = [NSMutableArray array];
    
    for (NSDictionary *subject in response) {
        NSString *subjectTitle = [NSString stringWithFormat:@"%@ (%@)",[subject[@"description"] capitalizedString],subject[@"code"]];
        [subjects addObject:[DataTuple tupleWithTitle:subjectTitle object:subject]];
    }
    
    return subjects;
}

@end
