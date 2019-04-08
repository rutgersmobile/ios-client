//
//  FAQViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/20/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "FAQViewController.h"
#import "ExpandingTableViewSection.h"
#import "FAQDataSource.h"
#import "RUChannelManager.h"
#import "NSDictionary+Channel.h"
#import "TTTAttributedLabel.h"
#import "RUWebViewController.h"

@interface FAQViewController<TTTAttributedLabelDelegate> ()
@property NSDictionary *channel;
@end

@implementation FAQViewController
+(NSString *)channelHandle{
    return @"faqview";
}
+(void)load{
    [[RUChannelManager sharedInstance] registerClass:[self class]];
}

+(instancetype)channelWithConfiguration:(NSDictionary *)channel{
    return [[self alloc] initWithChannel:channel];
}

-(instancetype)initWithChannel:(NSDictionary *)channel{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.channel = channel;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.dataSource = [[FAQDataSource alloc] initWithChannel:self.channel];
    self.dataSource = [[FAQDataSource alloc] initWithChannel:self.channel linkDelegate:self];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //Do super to 
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    id item = [self.dataSource itemAtIndexPath:indexPath];
    
    //If its a channel we need to open it
    if ([item isKindOfClass:[NSDictionary class]]) {
        //Either the item is the channel or has a channel
        NSDictionary *channel = item[@"channel"];
        if (!channel) channel = item;
        
        //Get view controller for channel
        UIViewController *vc = [[RUChannelManager sharedInstance] viewControllerForChannel:channel];
        vc.title = [item channelTitle];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

//Allow copy pasting on body rows
-(BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath{
    return (indexPath.row == 1);
}
-(BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender{
    return (indexPath.row == 1 && action == @selector(copy:));
}

//Copy the item description to the pasteboard
-(void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender{
    if (action != @selector(copy:)) return;
    [UIPasteboard generalPasteboard].string = [[self.dataSource itemAtIndexPath:indexPath] description];
}

- (void)attributedLabel:(TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url {
    NSLog(@"Link is %@", url);
    if ([[url absoluteString] rangeOfString:@"tel"].location == NSNotFound) {
        RUWebViewController* vc = [[RUWebViewController alloc] initWithURL:url];
        [self.navigationController pushViewController:vc animated:false];
    } else {
       // NSString* urlString = [[url absoluteString] stringByReplacingOccurrencesOfString:@"tel:" withString:""];
        [[UIApplication sharedApplication] openURL:url];
        NSLog(@"This is a phone number");
    }
}

@end
