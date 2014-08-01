//
//  SearchDataSource.h
//  Rutgers
//
//  Created by Kyle Bailey on 7/24/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SearchDataSource <NSObject>
-(void)updateForSearchString:(NSString *)searchString;
@end
