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
 
        Data is obtained from the network in multiple formats , this class allows us to use different formats 
    for obtaining the data from the servers
 
    Different classes for handling the JSON Objecct and the XML objects
 */

#import "RUResponseSerializer.h"
#import "AFXMLResponseSerializer.h"

@implementation RUResponseSerializer
+(AFCompoundResponseSerializer *)compoundResponseSerializer
{
    // set up json Serailizer
    AFJSONResponseSerializer *jsonSerializer = [AFJSONResponseSerializer serializer];
    jsonSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"application/json",@"text/json",@"text/html",nil];
    jsonSerializer.removesKeysWithNullValues = YES;
   
    // xml serilizer
    AFXMLResponseSerializer *xmlSerializer = [AFXMLResponseSerializer serializer];
    xmlSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"application/xml",@"text/xml",@"application/rss+xml",nil];

    return [self compoundSerializerWithResponseSerializers:@[xmlSerializer,jsonSerializer]];
}
@end
