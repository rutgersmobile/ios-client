//
//  RUReaderDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/30/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUReaderDataSource.h"
#import "RUReaderTableViewCell.h"
#import "RUReaderItem.h"
#import "DataSource_Private.h"
#import <UIKit+AFNetworking.h>
#import "RUNetworkManager.h"

@interface RUReaderDataSource ()
@property NSString *url;
@end

@implementation RUReaderDataSource
-(instancetype)initWithUrl:(NSString *)url{
    self = [super init];
    if (self) {
        self.url = url;
    }
    return self;
}

-(void)loadContent{
    [self loadContentWithBlock:^(AAPLLoading *loading) {
        [[RUNetworkManager readerSessionManager] GET:self.url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            if (!loading.current) {
                //If we have started another load, we should ignore this one
                [loading ignore];
                return;
            }
            
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                
                
                NSDictionary *channel = [responseObject[@"channel"] firstObject];
                NSArray *parsedResponse;
                if (responseObject[@"entry"] != nil) {
                    parsedResponse = [self parseAtomResponse:responseObject[@"entry"]];
                } else if(responseObject[@"games"]!=nil)
                {
                    parsedResponse = [self parseGameResponse:responseObject[@"games"]];
                }
                else
                {
                    parsedResponse = [self parseResponse:channel[@"item"]];
                }
                
                [loading updateWithContent:^(typeof(self) me) {
                    me.items = parsedResponse;
                }];
            } else {
                [loading updateWithContent:^(typeof(self) me) {
                    me.items = nil;
                }];
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [loading doneWithError:error];
        }];
    }];
}

-(NSArray *)parseAtomResponse:(NSArray *)response {
    NSMutableArray* parsedItems = [NSMutableArray array];
    for (NSDictionary *item in response) {
        RUReaderItem *row = [[RUReaderItem alloc] initWithAtom:item];
        [parsedItems addObject:row];
    }
    return parsedItems;
}

-(NSArray *)parseGameResponse:(NSArray *)response
{
    NSMutableArray *parsedItems = [NSMutableArray array];
    for (NSDictionary *item in response) {
        RUReaderItem *row = [[RUReaderItem alloc] initWithGame:item];
        [parsedItems addObject:row];
    }
    return parsedItems;
}

-(NSArray *)parseResponse:(NSArray *)response
{
    NSMutableArray *parsedItems = [NSMutableArray array];
    for (NSDictionary *item in response) {
        RUReaderItem *row = [[RUReaderItem alloc] initWithItem:item];
        [parsedItems addObject:row];
    }
    return parsedItems;
}

-(void)registerReusableViewsWithTableView:(UITableView *)tableView{
    [super registerReusableViewsWithTableView:tableView];
    [tableView registerClass:[RUReaderTableViewCell class] forCellReuseIdentifier:NSStringFromClass([RUReaderTableViewCell class])];
}

-(NSString *)reuseIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath{
    return NSStringFromClass([RUReaderTableViewCell class]);
}

-(void)configureCell:(RUReaderTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    RUReaderItem *row = [self itemAtIndexPath:indexPath];
    
    cell.titleLabel.text = row.title;
    cell.timeLabel.text = row.dateString;
    
    cell.hasImage = row.imageURL ? YES : NO;
    cell.imageDisplayView.backgroundColor = [UIColor grayColor];
    
    cell.imageDisplayView.image = nil;
    [cell.imageDisplayView setImageWithURL:row.imageURL];
    
    cell.descriptionLabel.text = row.descriptionText;
  //  cell.accessoryType = row.url ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
}


@end
