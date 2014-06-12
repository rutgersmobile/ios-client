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

/* See if we need to revert the toolbar to 'hidden' when we pop off a navigation controller. */
@property (nonatomic,assign) BOOL hideToolbarOnClose;

@property RUMapsData *mapsData;
@property AFHTTPSessionManager *sessionManager;
@property RUPlace *place;
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
//    self.mapView.boundingRect = MKMapRectMake(78674243.073795393, 101098420.93015477, 59715.507195115089, 71223.183060824871);
    self.mapView.delegate = self;
    self.mapsData = [RUMapsData sharedInstance];

    self.view = self.mapView;
    
    [self setupSession];
    [self setupOverlay];
    [self setupToolbar];
    
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
-(void)setupToolbar{
    //setup tracking toolbar
    UIBarButtonItem *trackingButton = [[MKUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    NSArray *barArray = @[flexibleSpace, trackingButton,flexibleSpace];
    [self setToolbarItems:barArray];

}
-(void)setupSession{
    self.sessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
    
    AFHTTPResponseSerializer *serializer = [AFHTTPResponseSerializer serializer];
    serializer.acceptableContentTypes = [NSSet setWithObject:@"image/png"];
    self.sessionManager.responseSerializer = serializer;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //see if we need to show the toolbar
    if (self.navigationController) {
        self.hideToolbarOnClose = self.navigationController.toolbarHidden;
        
        if (self.beingPresentedModally == NO) { //being pushed onto a pre-existing stack, so
            [self.navigationController setToolbarHidden:NO animated:animated];
            [self.navigationController setNavigationBarHidden:NO animated:animated];
        }
        else { //Being presented modally, so control the
            self.navigationController.toolbarHidden = NO;
        }
    }
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (self.beingPresentedModally == NO) {
        [self.navigationController setToolbarHidden:self.hideToolbarOnClose animated:animated];
    }
}
- (BOOL)beingPresentedModally
{
    // Check if we have a parentl navigation controller being presented modally
    if (self.navigationController)
        return ([self.navigationController presentingViewController] != nil);
    else // Check if we're directly being presented modally
        return ([self presentingViewController] != nil);
    
    return NO;
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
