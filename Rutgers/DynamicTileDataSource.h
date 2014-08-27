//
//  DynamicDataSource.h
//  Rutgers
//
//  Created by Kyle Bailey on 7/29/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "TileDataSource.h"
#import "TileCollectionViewItem.h"

@interface DynamicTileDataSource : TileDataSource
-(id)initWithUrl:(NSString *)url;
-(id)initWithItems:(NSArray *)items;

typedef enum : NSUInteger {
    kDynamicItemTypeChannel,
    kDynamicItemTypeList,
    kDynamicItemTypeFaq,
    kDynamicItemTypeUnknown
} kDynamicItemType;

-(kDynamicItemType)typeOfItem:(TileCollectionViewItem *)item;
@end
