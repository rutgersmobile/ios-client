//
//  AlertDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/18/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "AlertDataSource.h"
#import "DataSource_Private.h"
#import "DataTuple.h"
#import "ALTableViewTextCell.h"

@interface AlertDataSource () <UIActionSheetDelegate>
@property (nonatomic) NSArray *data;
@property (nonatomic) UIActionSheet *actionSheet;
@end

@implementation AlertDataSource
-(instancetype)initWithInitialText:(NSString *)initialText alertButtonTitles:(NSArray *)alertButtonTitles{
    self = [super initWithItems:@[initialText]];
    if (self) {
        self.actionSheet = [self makeActionSheetWithAlertButtonTitles:alertButtonTitles];
        self.showsDisclosureIndicator = YES;
        self.updatesInitialText = YES;
    }
    return self;
}

-(UIActionSheet *)makeActionSheetWithAlertButtonTitles:(NSArray *)alertButtonTitles{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    for (NSString *buttonTitle in alertButtonTitles) {
        [actionSheet addButtonWithTitle:buttonTitle];
    }
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];
    return actionSheet;
}

-(void)setAlertTitle:(NSString *)alertTitle{
    self.actionSheet.title = alertTitle;
}

-(NSString *)alertTitle{
    return self.actionSheet.title;
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == actionSheet.cancelButtonIndex || buttonIndex == actionSheet.destructiveButtonIndex || buttonIndex < 0){
        [self notifySectionsRefreshed:[NSIndexSet indexSetWithIndex:0]];
        return;
    }
    
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if (self.alertAction) self.alertAction(buttonTitle,buttonIndex);
    
    if (self.updatesInitialText){
        self.items = @[buttonTitle];
        [self invalidateCachedHeightsForSection:0];
    }
    
    [self notifySectionsRefreshed:[NSIndexSet indexSetWithIndex:0]];
}

-(void)showAlert{
    [self.actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}

-(void)registerReusableViewsWithTableView:(UITableView *)tableView{
    [super registerReusableViewsWithTableView:tableView];
    [tableView registerClass:[ALTableViewTextCell class] forCellReuseIdentifier:NSStringFromClass([ALTableViewTextCell class])];
}

-(NSString *)reuseIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath{
    return NSStringFromClass([ALTableViewTextCell class]);
}

-(NSInteger)numberOfItemsInSection:(NSInteger)section{
    return 1;
}

@end
