//
//  RUReaderDataSource.h
//  Rutgers
//
//  Created by Kyle Bailey on 7/30/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "BasicDataSource.h"

@interface RUReaderDataSource : BasicDataSource
-(instancetype)initWithUrl:(NSString *)url NS_DESIGNATED_INITIALIZER;
-(void)loadContentWithAnyBlock:(void(^)(void)) completionBlock; // temp addition 
@end
