//
//  RUResponseSerializer.m
//  Rutgers
//
//  Created by Open Systems Solutions on 4/15/15.
//  Copyright (c) 2015 Rutgers. All rights reserved.
//

/*
    Descrpit : 
            Serialize JSON and XML to do : 
            what ? 
 */

#import "RUResponseSerializer.h"
#import "AFXMLResponseSerializer.h"

@implementation RUResponseSerializer
+(AFCompoundResponseSerializer *)compoundResponseSerializer{
    AFJSONResponseSerializer *jsonSerializer = [AFJSONResponseSerializer serializer];
    jsonSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"application/json",@"text/json",@"text/html",nil];
    jsonSerializer.removesKeysWithNullValues = YES;
    
    AFXMLResponseSerializer *xmlSerializer = [AFXMLResponseSerializer serializer];
    xmlSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"application/xml",@"text/xml",@"application/rss+xml",nil];

    return [self compoundSerializerWithResponseSerializers:@[xmlSerializer,jsonSerializer]];
}
@end
