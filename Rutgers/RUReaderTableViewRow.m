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
#import <AFNetworking.h>
#import <UIKit+AFNetworking.h>
#import <NSDate+InternetDateTime.h>

@interface RUReaderTableViewRow ()
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *date;
@property (nonatomic) NSURL *imageURL;
@end

@implementation RUReaderTableViewRow
-(instancetype)initWithItem:(NSDictionary *)item{
    self = [super initWithIdentifier:@"RUReaderTableViewCell"];
    if (self) {
        self.title = [[item[@"title"] firstObject] stringByDecodingHTMLEntities];
        self.date = [item[@"pubDate"] firstObject];
        self.imageURL = [NSURL URLWithString:[item[@"enclosure"] firstObject][@"_url"]];
    }
    return self;
}

-(void)setupCell:(RUReaderTableViewCell *)cell{
    cell.titleLabel.text = self.title;
    cell.timeLabel.text = self.date;
    
    UIImage *placeHolder = [UIImage imageNamed:@"ABPicturePerson"];
    cell.hasImage = self.imageURL ? YES : NO;
    if (self.imageURL) {
        [cell.imageDisplayView setImageWithURL:self.imageURL placeholderImage:placeHolder];
    }
}

@end
