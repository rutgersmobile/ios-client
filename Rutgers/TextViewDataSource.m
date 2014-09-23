//
//  TextViewDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/29/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "TextViewDataSource.h"
#import "DataSource_Private.h"
#import "ALTableViewTextViewCell.h"

@interface TextViewDataSource () <UITextViewDelegate>
@end

@implementation TextViewDataSource
-(NSInteger)numberOfItems{
    return 1;
}

-(void)registerReusableViewsWithTableView:(UITableView *)tableView{
    [super registerReusableViewsWithTableView:tableView];
    [tableView registerClass:[ALTableViewTextViewCell class] forCellReuseIdentifier:NSStringFromClass([ALTableViewTextViewCell class])];
}

-(NSString *)reuseIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath{
    return NSStringFromClass([ALTableViewTextViewCell class]);
}

-(void)configureCell:(id)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    ALTableViewTextViewCell *textViewCell = cell;
    
    textViewCell.textView.text = self.textViewText;
    
    textViewCell.textView.delegate = self;
}

-(void)textViewDidChange:(UITextView *)textView{
    self.textViewText = textView.text;
}

-(void)resetContent{
    [super resetContent];
    self.textViewText = nil;
    [self notifySectionsRefreshed:[NSIndexSet indexSetWithIndex:0]];
}

@end
