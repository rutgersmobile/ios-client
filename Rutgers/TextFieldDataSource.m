//
//  ResponseDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/22/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "TextFieldDataSource.h"
#import "ALTableViewTextFieldCell.h"
#import "ALTableViewToggleCell.h"
#import "DataSource_Private.h"
#import "NSIndexPath+RowExtensions.h"

@implementation TextFieldDataSource
-(NSInteger)numberOfItems{
    return 1;
}

-(void)registerReusableViewsWithTableView:(UITableView *)tableView{
    [super registerReusableViewsWithTableView:tableView];
    [tableView registerClass:[ALTableViewTextFieldCell class] forCellReuseIdentifier:NSStringFromClass([ALTableViewTextFieldCell class])];
}

-(NSString *)reuseIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath{
    return NSStringFromClass([ALTableViewTextFieldCell class]);
}

-(void)textFieldDidUpdate:(UITextField *)textField{
    self.textFieldText = textField.text;
}

-(void)configureCell:(id)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    ALTableViewTextFieldCell *textFieldCell = cell;
    [textFieldCell.textField removeTarget:nil action:nil forControlEvents:UIControlEventEditingChanged];
    [textFieldCell.textField addTarget:self action:@selector(textFieldDidUpdate:) forControlEvents:UIControlEventEditingChanged];
   
    textFieldCell.textLabel.text = self.textFieldLabel;
    textFieldCell.textField.placeholder = self.textFieldPlaceholder;
    textFieldCell.textField.text = self.textFieldText;
}

-(void)resetContent{
    [super resetContent];
    self.textFieldText = nil;
    [self notifySectionsRefreshed:[NSIndexSet indexSetWithIndex:0]];
}

@end
