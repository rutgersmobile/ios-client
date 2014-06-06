//
//  RUMapsViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/8/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUMapsViewController.h"
#import <MapKit/MapKit.h>
#import "RUMapsTileOverlay.h"
#import "RUMapsData.h"
#import <AFNetworking.h>
#import <AFURLResponseSerialization.h>


@interface RUMapsViewController () <MKMapViewDelegate, RUMapsTileOverlayDelegate>
@property RUMapsData *mapsData;
@property AFURLSessionManager *sessionManager;
@end

@implementation RUMapsViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.delegate = self;
    self.mapsData = [RUMapsData sharedInstance];
    
    self.view = self.mapView;
    
    //add our overlay
    RUMapsTileOverlay *overlay = [[RUMapsTileOverlay alloc] init];
    overlay.delegate = self;
    [self.mapView addOverlay:overlay
               level:MKOverlayLevelAboveLabels];
    
    
    self.sessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
    AFHTTPResponseSerializer *serializer = [AFHTTPResponseSerializer serializer];
    serializer.acceptableContentTypes = [NSSet setWithObject:@"image/png"];
    self.sessionManager.responseSerializer = serializer;
    
    //make sure nothing gets rendered under the osm tiles
    self.mapView.showsBuildings = NO;
    self.mapView.showsPointsOfInterest = NO;
    
    //this looks weird so disable it
    self.mapView.pitchEnabled = NO;
    
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

-(void)cancelAllTasks{
    [self.sessionManager.tasks makeObjectsPerformSelector:@selector(cancel)];
}
-(void)dealloc{
    self.mapView.delegate = nil;
}

#pragma mark - MKMapViewDelegate
-(MKOverlayRenderer *)mapView:(MKMapView *)mapView
            rendererForOverlay:(id <MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKTileOverlay class]]) {
        return [[MKTileOverlayRenderer alloc] initWithTileOverlay:overlay];
    }
    
    return nil;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
