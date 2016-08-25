//
//  RUResponseSerializer.h
//  Rutgers
//
//  Created by Open Systems Solutions on 4/15/15.
//  Copyright (c) 2015 Rutgers. All rights reserved.
//

#import "AFURLResponseSerialization.h"

@interface RUResponseSerializer : AFCompoundResponseSerializer
+(AFCompoundResponseSerializer *)compoundResponseSerializer;
@end
