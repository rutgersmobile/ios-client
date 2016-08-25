//
//  RUSOCCourseDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/15/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUSOCCourseDataSource.h"
#import "RUSOCSectionCell.h"
#import "ALTableViewTextCell.h"
#import "RUSOCCourseSectionsDataSource.h"
#import "RUSOCDataLoadingManager.h"
#import "RUSOCCourseHeaderDataSource.h"
#import "DataSource_Private.h"

@interface RUSOCCourseDataSource ()
@property (nonatomic) NSDictionary *course;
@property (nonatomic) RUSOCCourseSectionsDataSource *sectionsDataSource;
@property (nonatomic) RUSOCCourseHeaderDataSource *headerDataSource;
@property (nonatomic) BOOL initialLoadComplete;
@property (nonatomic) RUSOCDataLoadingManager *dataLoadingManager;
@end

@implementation RUSOCCourseDataSource
-(instancetype)initWithCourse:(NSDictionary *)course dataLoadingManager:(RUSOCDataLoadingManager *)dataLoadingManager {
    self = [super init];
    if (self)
    {
        self.course = course;
        self.headerDataSource = [[RUSOCCourseHeaderDataSource alloc] init];
        self.sectionsDataSource = [[RUSOCCourseSectionsDataSource alloc] init];
        self.dataLoadingManager = dataLoadingManager;
    }
    return self;
}


/*




-(void) loadContentAndGetTitle:(AAPLLoading *) loading loadedCourses:(NSArray *)courses loadingError:(NSError *) courseLoadError
{
  /*
    [self.dataLoadingManager getSearchIndexWithCompletion:^
     (NSDictionary *index, NSError *error)
     {
         // find the id , set the title value..
         // get the title
         // index
         if (!loading.current)
         {
            [loading ignore];
            return;
         }
        
        if(! courseLoadError)
        {
           [loading updateWithContent:^(typeof(self) me)
            {
             
                 // parse out the title
         
                 for (NSString * key in [index allKeys]) // keys like names , ids , abber..
                 {
                     NSDictionary * dict = [index objectForKey:key] ;
                    
                     // get the dict corresponds to the names key  , we parse that dict as that has the subject title
                     if([key isEqualToString:@"names"])
                     {
                         // go through the dict and then find the name for the subject title
                         for(id key in dict)
                         {
                             NSInteger value = [[dict objectForKey:key] integerValue] ;
                             
                         //    NSLog(@"key=%@ value=%@", key, [dict objectForKey:key]);
                             // weird encoding . The course name is the key ( string ) , the course number is the value for the key
                             
                             if([self.subjectCode integerValue] == value)
                             {
                                 self.subjectTitle = key ; // this is the subject title
                                 break;
                             }
                         }
                         break ;
                     }
                 }          
                
                
                
                // Store the course list which was loaded in the previous block
                [self updateWithCourses:courses];
                
            }];
            
        }
         else
         {
             [loading doneWithError:courseLoadError];
         }
     }];
   */


/*
 
    In the case we do not have the  course name ( deep linking ) , then we can get it from the servers .. We do not have to do
    have to do a second request like for getting subject name as the we can get the course title from the request we send for getting the data about the course
 */

-(void)loadContent
{
    [self loadContentWithBlock:^(AAPLLoading *loading)
    {
        NSArray *sections = self.course[@"sections"];
        if (sections && !self.initialLoadComplete)
        {
            NSDictionary *course = self.course;
            [loading updateWithContent:^(typeof(self) me)
            {
                
              /*   [self.dataLoadingManager getSearchIndexWithCompletion:^
                (NSDictionary *index, NSError *error)
                  {
                  // get the title for the indexex.txt and set the course
                      
                      
                      
                
                  }];
               */
                // previous load
                [me updateWithCourse:course];
            }];
            self.initialLoadComplete = YES;
        }
        else
        {
            NSString *subjectCode = self.course[@"subjectCode"];
            if (!subjectCode) subjectCode = self.course[@"subject"];
            
            [self.dataLoadingManager getCourseForSubjectCode:subjectCode courseCode:self.course[@"courseNumber"] completion:^(NSDictionary *course, NSError *error)
            {
                if (!loading.current)
                {
                    [loading ignore];
                    return;
                }
                
                if (!error)
                {
                    [loading updateWithContent:^(typeof(self) me)
                    {
                        [me updateWithCourse:course];
                    }];
                }
                else
                {
                    [loading doneWithError:error];
                }
            }];
        }
    }];
    
}

-(void)updateWithCourse:(NSDictionary *)course
{
    
    self.course = course;
    self.courseTitle = course[@"title"]; // get the course title to set in the nav controller when deep linking
    [self removeAllDataSources];
    
    NSMutableDictionary *headerItems = [NSMutableDictionary dictionary];
    for (NSString *key in @[@"subjectNotes",@"preReqNotes",@"synopsisUrl",@"credits"])
    {
        id value = course[key];
        if (value) headerItems[key] = value;
    }
    
    if (headerItems.count) {
        self.headerDataSource.headerItems = headerItems;
        [self addDataSource:self.headerDataSource];
    }
    
    [self.sectionsDataSource loadContentWithBlock:^(AAPLLoading *loading) {
       [loading updateWithContent:^(typeof(self.sectionsDataSource) sectionsDataSource) {
           sectionsDataSource.items = course[@"sections"];
       }];
    }];
    [self addDataSource:self.sectionsDataSource];
}

-(void)registerReusableViewsWithTableView:(UITableView *)tableView{
    [super registerReusableViewsWithTableView:tableView];
    [tableView registerClass:[RUSOCSectionCell class] forCellReuseIdentifier:NSStringFromClass([RUSOCSectionCell class])];
    [tableView registerClass:[ALTableViewTextCell class] forCellReuseIdentifier:NSStringFromClass([ALTableViewTextCell class])];
}

@end
