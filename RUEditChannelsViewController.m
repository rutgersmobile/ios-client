//
//  RUEditChannelsViewController.m
//  Rutgers
//
//  Created by scm on 5/26/16.
//  Copyright © 2016 Rutgers. All rights reserved.
//

#import "RUEditChannelsViewController.h"
#import "DataSource.h"
#import "RUChannelManager.h"
#import "NSDictionary+Channel.h" // categories :: For obtaining the title and image from channel



@interface RUEditChannelsViewController ()
@end

@implementation RUEditChannelsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSource = [RUMenuMultipleDataSource sharedManager];
   
    // add edit option to navigation controller
    
    self.navigationItem.rightBarButtonItem =[[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editDataSource)];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    NSDictionary *item = [self.dataSource objectAtIndex:indexPath.row];
    if( [item[@"isFavourite"] boolValue])
    {
        NSString *channelHandle = [[NSURL URLWithString:item[@"url"]] host];
        
        // obtain the channel with the handle
        NSDictionary *channel = [[RUChannelManager sharedInstance] channelWithHandle:channelHandle];
        
        cell.textLabel.text = [channel channelTitle];
        cell.imageView.image = [channel channelIcon];
        
    }
    else // channel
    {
        cell.textLabel.text = [item channelTitle];
        cell.imageView.image = [item channelIcon];
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource numberOfObjects];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
