//
//  RUSOCViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/29/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUSOCViewController.h"
#import "RUSOCDataSource.h"
#import "RUSOCSearchDataSource.h"
#import "RUSOCSubjectViewController.h"
#import "RUSOCCourseViewController.h"
#import "RUSOCOptionsViewController.h"
#import "RUSOCDataLoadingManager.h"
#import "DataTuple.h"
#import "TableViewController_Private.h"
#import "RUChannelManager.h"
#import "RUFavoritesErrorViewController.h"
#import "NSURL+RUAdditions.h"

// User Defaults to set the values if it is not specified
#import "RUUserInfoManager.h"

@interface RUSOCViewController () <UISearchDisplayDelegate, RUSOCOptionsDelegate>
@property (nonatomic) UIBarButtonItem *optionsButton;
@property BOOL optionsDidChange;
@property (nonatomic) RUSOCDataLoadingManager *dataLoadingManager;
@end

@implementation RUSOCViewController
+(NSString *)channelHandle{
    return @"soc";
}

+(void)load{
    [[RUChannelManager sharedInstance] registerClass:[self class]];
}

+(instancetype)channelWithConfiguration:(NSDictionary *)channel{
    return [[self alloc] initWithStyle:UITableViewStylePlain];
}

-(RUSOCDataLoadingManager *)dataLoadingManager{
    if (!_dataLoadingManager) {
        return [RUSOCDataLoadingManager sharedInstance];
    }
    return _dataLoadingManager;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //self.optionsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"options"] style:UIBarButtonItemStylePlain target:self action:@selector(optionsButtonPressed)];

   
    // set both the sharing and options button
    // sharing button is setup in the super class O
    
    UIButton *settingsView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [settingsView addTarget:self action:@selector(optionsButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [settingsView setBackgroundImage:[UIImage imageNamed:@"gear"] forState:UIControlStateNormal];
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithCustomView:settingsView];
    
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:self.shareButton  , settingsButton , nil]];
    //self.navigationItem.rightBarButtonItem = self.optionsButton;
    
    self.dataSource = [[RUSOCDataSource alloc] init];
    self.searchDataSource = [[RUSOCSearchDataSource alloc] init];
    self.searchBar.placeholder = @"Search Subjects and Courses";
    
    self.tableView.sectionIndexMinimumDisplayRowCount = 20;
    
    [((RUSOCSearchDataSource *)self.searchDataSource) setNeedsLoadIndex];
    
    [self setInterfaceEnabled:NO animated:NO];
}

-(void)dataSource:(DataSource *)dataSource didLoadContentWithError:(NSError *)error{
    [super dataSource:dataSource didLoadContentWithError:error];
    if (!error) {
        self.title = self.dataLoadingManager.titleForCurrentConfiguration;
        [self setInterfaceEnabled:YES animated:YES];
    }
}

-(NSURL *)sharingURL{
    RUSOCDataLoadingManager *manager = self.dataLoadingManager;
 
 
    /*
    if(manager.semester == nil)
    {
        NSLog(@"ERROR");
        [manager performWhenSemestersLoaded:^(NSError *error) {
            NSLog(@"semsester Load error %@" ,error);
        }];
        
    }
     
     
     When the course is directly accessed from the favourties , without going through the
    heirarchy , the manager.semester returns nil , as that is filled by a RUCource
     
    */
    
    return [NSURL rutgersUrlWithPathComponents:@[
                                                 @"soc",
                                                 manager.semester[@"tag"],
                                                 ]];
}


-(void)setInterfaceEnabled:(BOOL)enabled animated:(BOOL)animated{
    self.optionsButton.enabled = enabled;
}
    
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (self.optionsDidChange) {
        [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (self.optionsDidChange) {
        [self.dataSource resetContent];
        [self.dataSource setNeedsLoadContent];
        
        [((RUSOCSearchDataSource *)self.searchDataSource) setNeedsLoadIndex];
        
        self.optionsDidChange = NO;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DataTuple *item = [[self dataSourceForTableView:tableView] itemAtIndexPath:indexPath];
   
    if (item.object[@"courseNumber"]) {
        RUSOCCourseViewController *courseVC = [[RUSOCCourseViewController alloc] initWithCourse:item.object];
        courseVC.dataLoadingManager = self.dataLoadingManager;
        [self.navigationController pushViewController:courseVC animated:YES];
    } else {
        RUSOCSubjectViewController *subjectVC = [[RUSOCSubjectViewController alloc] initWithSubject:item.object];
        subjectVC.dataLoadingManager = self.dataLoadingManager;
        [self.navigationController pushViewController:subjectVC animated:YES];
    }
}

-(void)optionsButtonPressed{
    [self.navigationController pushViewController:[[RUSOCOptionsViewController alloc] initWithDelegate:self] animated:YES];
}

-(void)optionsViewControllerDidChangeOptions:(RUSOCOptionsViewController *)optionsViewController{
    self.optionsDidChange = YES;
    self.title = [RUSOCDataLoadingManager sharedInstance].titleForCurrentConfiguration;
}

+(NSArray *)viewControllersWithPathComponents:(NSArray *)pathComponents destinationTitle:(NSString *)title
{

    
    NSString *semester;
    NSString *campus;
    NSString *level;
    NSString *subjectCode;
    
    
    NSString *courseNumber;
    
    // Used to see if semester / subject / course codes are valid
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    
    // Used to store integer codes
    NSMutableArray *codes = [[NSMutableArray alloc] init];
    
    for (NSString *component in pathComponents)
    {
        // All codes are uppercase
        NSString *upper = [component uppercaseString]; // covert to upper case
        
        if ([upper isEqualToString:@"NB"] || [upper isEqualToString:@"CM"] ||  [upper isEqualToString:@"NK"] || [upper isEqualToString:@"ONLINE"])
        {
            // All possible campus codes
            campus = upper ; // convert to lower case for getting the data from the server ..
        }
        else if ([upper isEqualToString:@"U"] || [upper isEqualToString:@"G"])
        {
            // All possible level codes
            level = upper ;
        }
        else
        {
            // Only thing left is integer based codes, which we collect in order
            NSNumber *code = [f numberFromString:upper];
            if (code != nil)
            {
                [codes addObject:upper];
            }
            else
            {
                // If we've gotten this far then the pathComponent is invalid
                return @[[[RUFavoritesErrorViewController alloc] init]];
            }
        }
    }
    
    
    // We go through the integer codes for semester, subject, and course
    if ([codes count] > 0)
    {
        // The semester code could be anywhere in the list
        for (int i = 0; i < [codes count]; i++)
        {
            NSString *code = codes[i];
            // The semester code is always at least 4 characters
            // The subject and course codes are always 3
            if (code.length > 3)
            {
                semester = codes[i];
                [codes removeObjectAtIndex:i];
            }
        }
    
        // The only thing left should be subject and course codes
        // These look identical and subject is required so it will always be
        // <subjectCode> or <subjectCode>/<courseCode>
        if ([codes count] > 0)
        {
            subjectCode = codes[0];
            [codes removeObjectAtIndex:0];
            if ([codes count] > 0)
            {
                courseNumber = codes[0];
                [codes removeObjectAtIndex:0];
            }
        }
    }
        
    // Leftover junk is an error
    if ([codes count] > 0)
    {
        return @[[[RUFavoritesErrorViewController alloc] init]];
    }
    
    // Missing components is an error
    // TODO subjectCode is optional on Android
  
    if(campus == nil)
    {
        campus = [RUUserInfoManager currentCampus][@"tag"];
    }

    // Default to undergraduate
    // May want to default other fields in the future
    if (level == nil)
    {
        level = [RUUserInfoManager currentUserRole][@"tag"];
    }

    if (semester == nil)
    {
        return @[[[RUFavoritesErrorViewController alloc] init]];
    }

    if (subjectCode == nil )
    {
        RUSOCViewController * vc = [[RUSOCViewController alloc] init];
        return @[vc];
        // LINK TO MAIN SOC PAGE
    }

    RUSOCDataLoadingManager *manager = [RUSOCDataLoadingManager managerForSemesterTag:semester campusTag:campus levelTag:level];
    if (!manager) return @[[[RUFavoritesErrorViewController alloc] init]];
   
 
    if(title == nil)
    {
       title = @"";
    }
    
    if (courseNumber)
    {
       
        NSDictionary *course = @{
                                 @"subjectCode": subjectCode,
                                 @"courseNumber": courseNumber,
                                 @"title": title
                                 };
        RUSOCCourseViewController *vc = [[RUSOCCourseViewController alloc] initWithCourse:course];
        vc.dataLoadingManager = manager;
        return @[vc];
    }
    else
    {
       
        NSDictionary *subject = @{
                                  @"code": subjectCode,
                                  @"description": title
                                  };
        RUSOCSubjectViewController *vc = [[RUSOCSubjectViewController alloc] initWithSubject:subject];
        vc.dataLoadingManager = manager;
        return @[vc];
    }
    

}

@end
