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
@property (nonatomic) UILocalizedIndexedCollation *collation;
@property (nonatomic) RUSOCDataLoadingManager *dataLoadingManager;
@end

@implementation RUSOCDataSource

-(instancetype)init{
    self = [super init];
    if (self) {
        self.title = @"Subjects";
        self.collation = [UILocalizedIndexedCollation currentCollation];
    }
    return self;
}

-(RUSOCDataLoadingManager *)dataLoadingManager{
    if (!_dataLoadingManager) {
        return [RUSOCDataLoadingManager sharedInstance];
    }
    return _dataLoadingManager;
}

-(void)setItems:(NSArray *)items{
    NSMutableDictionary *sectionIndexMapping = [NSMutableDictionary dictionary];
    for (DataTuple *item in items) {
        NSInteger index = [self.collation sectionForObject:item collationStringSelector:@selector(title)];
        NSString *indexTitle = self.collation.sectionIndexTitles[index];
        NSMutableArray *section = sectionIndexMapping[indexTitle];
        if (!section) {
            section = [NSMutableArray array];
            sectionIndexMapping[indexTitle] = section;
        }
        [section addObject:item];
    }
    
    NSArray *sectionIndexTitles = self.collation.sectionIndexTitles;
    _sectionIndexTitles = sectionIndexTitles;
  
    [self removeAllDataSources];

    for (NSString *indexTitle in sectionIndexTitles) {
        TupleDataSource *dataSource = [[TupleDataSource alloc] initWithItems:sectionIndexMapping[indexTitle]];
        dataSource.title = indexTitle;
        [self addDataSource:dataSource];
    }
}

-(void)registerReusableViewsWithTableView:(UITableView *)tableView{
    [super registerReusableViewsWithTableView:tableView];
    [tableView registerClass:[ALTableViewTextCell class] forCellReuseIdentifier:NSStringFromClass([ALTableViewTextCell class])];
}

-(NSString *)reuseIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath{
    return NSStringFromClass([ALTableViewTextCell class]);
}

/*
-(NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    return self.sectionIndexTitles;
}

-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    return index;
}*/

-(void)loadContent{
  //  [self removeAllDataSources];
    
    [self loadContentWithBlock:^(AAPLLoading *loading) {
        [self.dataLoadingManager getSubjectsWithCompletion:^(NSArray *subjects, NSError *error) {
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
