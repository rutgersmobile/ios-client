//
//  dcollection.h
//  Rutgers
//
//  Created by Kyle Bailey on 6/3/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "ColoredTileCollectionViewController.h"

@interface DynamicCollectionViewController : ColoredTileCollectionViewController <RUComponentProtocol>
-(instancetype)initWithChildren:(NSArray *)children;
@end
