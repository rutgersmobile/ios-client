//
//  RUReaderTableViewRow.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/27/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUReaderTableViewRow.h"
#import <NSString+HTML.h>
#import "RUReaderTableViewCell.h"
#import <TOWebViewController.h>
#import <AFNetworking.h>
#import <UIKit+AFNetworking.h>
#import <NSDate+InternetDateTime.h>

@interface RUReaderTableViewRow ()

@end
@implementation RUReaderTableViewRow
-(instancetype)initWithItem:(NSDictionary *)item{
    self = [super initWithIdentifier:@"RUReaderTableViewCell"];
    if (self) {
        self.title = [[item[@"title"] firstObject] stringByDecodingHTMLEntities];
        self.date = [item[@"pubDate"] firstObject];
        self.url = [NSURL URLWithString:[item[@"enclosure"] firstObject][@"_url"]];
    }
    return self;
}

-(void)setupCell:(RUReaderTableViewCell *)cell{
    cell.titleLabel.text =  self.title;
    cell.timeLabel.text = self.date;
    
    UIImage *placeHolder = [UIImage imageNamed:@"ABPicturePerson"];
    if (self.url) {
        [cell.imageDisplayView setImageWithURL:self.url placeholderImage:placeHolder];
    } else {
        cell.imageDisplayView.image = placeHolder;
    }
}

@end
