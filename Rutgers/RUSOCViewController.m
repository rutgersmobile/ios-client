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
    
    self.optionsButton = [[UIBarButtonItem alloc] initWithTitle:@"Options" style:UIBarButtonItemStylePlain target:self action:@selector(optionsButtonPressed)];
    self.navigationItem.rightBarButtonItem = self.optionsButton;
    
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
        NSString *upper = [component uppercaseString];
        
        if ([upper isEqualToString:@"NB"] || [upper isEqualToString:@"CM"] ||  [upper isEqualToString:@"NK"] || [upper isEqualToString:@"ONLINE"])
        {
            // All possible campus codes
            campus = [upper lowercaseString];
        }
        else if ([upper isEqualToString:@"U"] || [upper isEqualToString:@"G"])
        {
            // All possible level codes
            level = [upper lowercaseString];
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
    
    if (semester == nil || campus == nil || subjectCode == nil)
    {
        return @[[[RUFavoritesErrorViewController alloc] init]];
    }
    
    // Default to undergraduate
    // May want to default other fields in the future
    if (level == nil)
    {
    
        level = @"U";
    }
    
    RUSOCDataLoadingManager *manager = [RUSOCDataLoadingManager managerForSemesterTag:semester campusTag:campus levelTag:level];
    if (!manager) return @[[[RUFavoritesErrorViewController alloc] init]];
    
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
    
     /*
    if (pathComponents.count < 4) return @[[[RUFavoritesErrorViewController alloc] init]];
    
    NSString *semester = pathComponents[0];
    NSString *campus = pathComponents[1];
    NSString *level = pathComponents[2];
    NSString *subjectCode = pathComponents[3];
    NSString *courseNumber;
    
    if (pathComponents.count > 4) { courseNumber = pathComponents[4]; }
    
    RUSOCDataLoadingManager *manager = [RUSOCDataLoadingManager managerForSemesterTag:semester campusTag:campus levelTag:level];
    if (!manager) return @[[[RUFavoritesErrorViewController alloc] init]];
    
    if (courseNumber) {
        NSDictionary *course = @{
                                 @"subjectCode": subjectCode,
                                 @"courseNumber": courseNumber,
                                 @"title": title
                                 };
        RUSOCCourseViewController *vc = [[RUSOCCourseViewController alloc] initWithCourse:course];
        vc.dataLoadingManager = manager;
        return @[vc];
    } else {
        NSDictionary *subject = @{
                                  @"code": subjectCode,
                                  @"description": title
                                  };
        RUSOCSubjectViewController *vc = [[RUSOCSubjectViewController alloc] initWithSubject:subject];
        vc.dataLoadingManager = manager;
        return @[vc];
    }
    
   */
}

@end
