//
//  RUMapsTileOverlay.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/9/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUMapsTileOverlay.h"
#import "RUMapsData.h"
#import "iPadCheck.h"

@interface RUMapsTileOverlay ()
@property BOOL retina;
@property AFHTTPSessionManager *sessionManager;
@end

@implementation RUMapsTileOverlay
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.canReplaceMapContent = YES;
        
        self.sessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
        
        AFHTTPResponseSerializer *serializer = [AFHTTPResponseSerializer serializer];
        serializer.acceptableContentTypes = [NSSet setWithObject:@"image/png"];
        self.sessionManager.responseSerializer = serializer;
        self.sessionManager.operationQueue.maxConcurrentOperationCount = 16;
    }
    return self;
}

-(void)loadTileAtPath:(MKTileOverlayPath)path result:(void (^)(NSData *data, NSError *error))result{
    RUMapsData *mapsData = [RUMapsData sharedInstance];
    
    NSData *cachedData = [mapsData cachedDataForTilePath:path];
    if (cachedData) {
        result(cachedData, nil);
    } else {
        NSURLRequest *request = [NSURLRequest requestWithURL:[mapsData URLForTilePath:path]];
        NSURLSessionDataTask *dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if ([[response MIMEType] isEqualToString:@"image/png"]) {
                [mapsData setCachedData:responseObject forTilePath:path];
                result(responseObject,error);
            } else {
                result(nil,error);
            }
        }];
        [dataTask resume];
    }

}

-(void)dealloc{
    [self.sessionManager invalidateSessionCancelingTasks:YES];
}


@end