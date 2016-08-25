//
//  RUSOCSubjectDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/30/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUSOCSubjectDataSource.h"
#import "RUSOCCourseRow.h"
#import "RUSOCDataLoadingManager.h"
#import "RUSOCCourseCell.h"
#import "DataSource_Private.h"

@interface RUSOCSubjectDataSource ()
@property (nonatomic) RUSOCDataLoadingManager *dataLoadingManager;
@property (nonatomic) NSString *subjectCode;
@end

@implementation RUSOCSubjectDataSource
-(instancetype)initWithSubjectCode:(NSString *)subjectCode dataLoadingManager:(RUSOCDataLoadingManager *)dataLoadingManager{
    self = [super init];
    if (self) {
        self.subjectCode = subjectCode;
        self.title = @"Courses";
        self.dataLoadingManager = dataLoadingManager;
    }
    return self;
}

-(void)loadContent
{
    [self loadContentWithBlock:^(AAPLLoading *loading)
    {
        [self.dataLoadingManager getCoursesForSubjectCode:self.subjectCode completion:^(NSArray *courses, NSError *error)
         {
             // we need to get the title for the view  controller too. We do this by chainning another request , which will be called in this
            // completion handler and then , calling telling the super classs that data was loaded in the chained request
             [self loadContentAndGetTitle:loading loadedCourses:courses loadingError:error];
        }];
    }];
}




-(void) loadContentAndGetTitle:(AAPLLoading *) loading loadedCourses:(NSArray *)courses loadingError:(NSError *) courseLoadError
{

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
        
        if(! courseLoadError && ! error)
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
    
    
}


-(void)updateWithCourses:(NSArray *)courses{
    NSMutableArray *parsedItems = [NSMutableArray array];
    for (NSDictionary *course in courses)
    {
       // We are not adding a course if there are no sections in it.
        
        NSPredicate *printedSectionsPredicate = [NSPredicate predicateWithFormat:@"printed == %@",@"Y"];
        
        NSArray *sections = [course[@"sections"] filteredArrayUsingPredicate:printedSectionsPredicate];
        
       if(sections.count != 0)
       {
           RUSOCCourseRow *row = [[RUSOCCourseRow alloc] initWithCourse:course];
           [parsedItems addObject:row];
       }
       
    }
    self.items = parsedItems;
}



-(void)registerReusableViewsWithTableView:(UITableView *)tableView{
    [super registerReusableViewsWithTableView:tableView];
    [tableView registerClass:[RUSOCCourseCell class] forCellReuseIdentifier:NSStringFromClass([RUSOCCourseCell class])];
}

-(NSString *)reuseIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath{
    return NSStringFromClass([RUSOCCourseCell class]);
}

-(void)configureCell:(RUSOCCourseCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    RUSOCCourseRow *row = [self itemAtIndexPath:indexPath];
    
    cell.titleLabel.text = row.titleText;
    cell.creditsLabel.text = row.creditsText;
    cell.sectionsLabel.text = row.sectionText;
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}
@end
