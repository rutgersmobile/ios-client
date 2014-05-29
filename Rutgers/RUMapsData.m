//
//  RUMapsData.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/8/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUMapsData.h"
#import <AFNetworking.h>
#import <AFURLResponseSerialization.h>
@interface RUMapsData ()
@property NSCache *cache;
@property AFURLSessionManager *sessionManager;
@end

@implementation RUMapsData
+(RUMapsData *)sharedInstance{
    static RUMapsData *mapsData = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mapsData = [[RUMapsData alloc] init];
    });
    return mapsData;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cache = [[NSCache alloc] init];
        
        self.sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
        AFHTTPResponseSerializer *serializer = [AFHTTPResponseSerializer serializer];
        serializer.acceptableContentTypes = [NSSet setWithObject:@"image/png"];
        
        self.sessionManager.responseSerializer = serializer;
    }
    return self;
}

- (NSURL *)URLForTilePath:(MKTileOverlayPath)path {
    static NSString * const template = @"http://tile.openstreetmap.org/%ld/%ld/%ld.png";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:template, (long)path.z, (long)path.x, (long)path.y]];
    return url;
}

- (void)loadTileAtPath:(MKTileOverlayPath)path
                result:(void (^)(NSData *data, NSError *error))result
{
    if (!result) {
        return;
    }
    
    NSURL *url = [self URLForTilePath:path];
    NSData *cachedData = [self.cache objectForKey:url];
    if (cachedData) {
        result(cachedData, nil);
    } else {
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        NSURLSessionDataTask *dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (!error &&
                [responseObject isKindOfClass:[NSData class]] &&
                [[response MIMEType] isEqualToString:@"image/png"]) {
                [self.cache setObject:responseObject forKey:url cost:[((NSData *)responseObject) length]];
            }
            result(responseObject, error);
        }];
        [dataTask resume];
    }
}

@end

