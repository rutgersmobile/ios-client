//
//  RUMapsTileOverlay.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/9/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUMapsTileOverlay.h"
#import "RUMapsData.h"
#import <AFNetworking.h>
#import <AFURLResponseSerialization.h>

@interface RUMapsTileOverlay ()
@property BOOL validSession;
@property AFURLSessionManager *sessionManager;
@property RUMapsData *mapsData;
@end

@implementation RUMapsTileOverlay
-(id)init{
    self = [super init];
    if (self) {
        self.canReplaceMapContent = YES;
        self.mapsData = [RUMapsData sharedInstance];
        self.validSession = YES;
        [self makeSession];
    }
    return self;
}
-(void)loadTileAtPath:(MKTileOverlayPath)path result:(void (^)(NSData *, NSError *))result{
    if (!self.validSession) {
        return;
    }
    NSURL *url = [self URLForTilePath:path];
    NSData *cachedData = [self.mapsData.cache objectForKey:url];
    if (cachedData) {
        result(cachedData, nil);
    } else {
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        NSURLSessionDataTask *dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (!error && [responseObject isKindOfClass:[NSData class]] && [[response MIMEType] isEqualToString:@"image/png"]) {
                [self.mapsData.cache setObject:responseObject forKey:url cost:[((NSData *)responseObject) length]];
                result(responseObject,error);
            } else {
                [self loadTileAtPath:path result:result];
            }
        }];
        [dataTask resume];
    }
}
- (NSURL *)URLForTilePath:(MKTileOverlayPath)path {
    static NSString * const template = @"http://tile.openstreetmap.org/%ld/%ld/%ld.png";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:template, (long)path.z, (long)path.x, (long)path.y]];
    return url;
}
-(void)makeSession{
    AFURLSessionManager * sessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
    AFHTTPResponseSerializer *serializer = [AFHTTPResponseSerializer serializer];
    serializer.acceptableContentTypes = [NSSet setWithObject:@"image/png"];
    sessionManager.responseSerializer = serializer;
    self.sessionManager = sessionManager;
}
-(void)invalidateSession{
    self.validSession = NO;
    [self.sessionManager invalidateSessionCancelingTasks:YES];
}
-(void)dealloc{
    [self invalidateSession];
}
@end