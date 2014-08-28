//
//  CollectionViewController.h
//  Rutgers
//
//  Created by Kyle Bailey on 7/29/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataSource.h"

@interface CollectionViewController : UICollectionViewController
-(DataSource *)dataSource;
-(void)setDataSource:(DataSource *)dataSource;

-(void)preferredContentSizeChanged NS_REQUIRES_SUPER;
@end
