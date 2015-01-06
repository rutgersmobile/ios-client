/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  A data source that populates its cells based on key/value information from a source object. The items in the data source are NSDictionary instances with the keys @"label" and @"keyPath". Any items for which the object does not have a value will not be displayed.
  
 */

#import "KeyValueDataSource.h"
#import "ALTableViewRightDetailCell.h"

static NSString * const AAPLKeyValueDataSourceKeyPathKey = @"keyPath";
static NSString * const AAPLKeyValueDataSourceLabelKey = @"label";

@interface KeyValueDataSource ()
@property (nonatomic, strong) id object;
@end

@implementation KeyValueDataSource

- (instancetype)init
{
    return [self initWithObject:nil];
}

- (instancetype)initWithObject:(id)object
{
    self = [super init];
    if (!self)
        return nil;

    _object = object;
    return self;
}

- (void)setItems:(NSArray *)items
{
    // Filter out any items that don't have a value, because it looks sloppy when rows have a label but no value
    NSMutableArray *newItems = [NSMutableArray array];
    for (NSDictionary *dictionary in items) {
        id value = [self.object valueForKeyPath:dictionary[AAPLKeyValueDataSourceKeyPathKey]];
        if (value)
            [newItems addObject:dictionary];
    }
    [super setItems:newItems];
}

-(id)itemAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dictionary = [super itemAtIndexPath:indexPath];
    return [self.object valueForKeyPath:dictionary[AAPLKeyValueDataSourceKeyPathKey]];
}

-(void)registerReusableViewsWithTableView:(UITableView *)tableView{
    [super registerReusableViewsWithTableView:tableView];
    [tableView registerClass:[ALTableViewRightDetailCell class] forCellReuseIdentifier:NSStringFromClass([ALTableViewRightDetailCell class])];
}

-(NSString *)reuseIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath{
    return NSStringFromClass([ALTableViewRightDetailCell class]);
}

-(void)configureCell:(ALTableViewRightDetailCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dictionary = [super itemAtIndexPath:indexPath];
    
    cell.detailTextLabel.text = dictionary[AAPLKeyValueDataSourceLabelKey];

    NSString *valueString;
    id value = [self.object valueForKeyPath:dictionary[AAPLKeyValueDataSourceKeyPathKey]];
    
    valueString = value;

    cell.textLabel.text = valueString;
}

@end
