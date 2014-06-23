//
//  RUMapsViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/8/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUMapsViewController.h"
#import "RUPlace.h"
#import <MapKit/MapKit.h>
#import "RUMapsTileOverlay.h"
#import "RUMapsData.h"
#import <AFNetworking.h>
#import <AFURLResponseSerialization.h>

@interface RUMapsViewController () <RUMapsTileOverlayDelegate>

@property RUMapsData *mapsData;
@property AFHTTPSessionManager *sessionManager;

@end


@implementation RUMapsViewController

-(id)initWithPlace:(RUPlace *)place{
    self = [super init];
    if (self) {
        self.place = place;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.delegate = self;
    self.mapView.opaque = YES;
    self.mapsData = [RUMapsData sharedInstance];

    self.view = self.mapView;
    
    [self setupSession];
    [self setupOverlay];
    
    self.navigationItem.rightBarButtonItem = [[MKUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];
    
    if (self.place) {
        [self loadPlace];
    }
}

-(void)loadPlace{
    self.title = self.place.title;
    if (self.place.location) {
        [self zoomToPlace];
    } else {
        CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
        
        void(^completion)(NSArray *placemarks, NSError *error) = ^(NSArray *placemarks, NSError *error){
            MKPlacemark *placeMark = [placemarks firstObject];
            self.place.location = placeMark.location;
            [self zoomToPlace];
        };
        
        if (self.place.address) {
            [geoCoder geocodeAddressDictionary:self.place.address completionHandler:completion];
        } else if (self.place.addressString){
            [geoCoder geocodeAddressString:self.place.addressString completionHandler:completion];
        }
    }
}

-(void)zoomToPlace{
    [self.mapView addAnnotation:self.place];
    [self.mapView showAnnotations:@[self.place] animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)setupOverlay{
    //add our overlay
    RUMapsTileOverlay *overlay = [[RUMapsTileOverlay alloc] init];
    overlay.delegate = self;
    [self.mapView addOverlay:overlay
                       level:MKOverlayLevelAboveLabels];
    
    //make sure nothing gets rendered under the osm tiles
    self.mapView.showsBuildings = NO;
    self.mapView.showsPointsOfInterest = NO;
    
    //this looks weird so disable it
    self.mapView.pitchEnabled = NO;
}

-(void)setupSession{
    self.sessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
    
    AFHTTPResponseSerializer *serializer = [AFHTTPResponseSerializer serializer];
    serializer.acceptableContentTypes = [NSSet setWithObject:@"image/png"];
    self.sessionManager.responseSerializer = serializer;
    self.sessionManager.operationQueue.maxConcurrentOperationCount = 20;
}


- (NSURL *)URLForTilePath:(MKTileOverlayPath)path {
    static NSString * const template = @"http://sauron.rutgers.edu/maps/%ld/%ld/%ld.png";
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
                //[self loadTileAtPath:path result:result];
                NSLog(@"Error loading tile: %@",[self URLForTilePath:path]);
                result(nil,error);
            }
        }];
        [dataTask resume];
    }
}

-(void)cancelAllTasks{
    [self.sessionManager invalidateSessionCancelingTasks:YES];
}

-(void)dealloc{
    [self cancelAllTasks];
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



@end
