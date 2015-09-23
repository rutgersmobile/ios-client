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
#import "RUOSMDataLoadingManager.h"

@interface RUMapsViewController ()
@property RUMapsData *mapsData;
@property BOOL usesOSM;
@end


@implementation RUMapsViewController
-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    return [self initWithPlace:nil];
}
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    return [self initWithPlace:nil];
}

-(instancetype)initWithPlace:(RUPlace *)place{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        if (place) {
            self.place = place;
        }
    }
    return self;
}

-(void)loadView{
    [super loadView];
    self.mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.delegate = self;
    self.mapView.opaque = YES;
    self.mapView.showsUserLocation = YES;
    
    
    self.view = self.mapView;
    [self.mapView setVisibleMapRect:MKMapRectMake(78609409.062235206, 100781568.35516316, 393216.0887889266, 462848.10451197624)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[RUOSMDataLoadingManager sharedManager] get];

    // Do any additional setup after loading the view.
   
   // self.usesOSM = YES;
    
    if (self.usesOSM) {
        self.mapsData = [RUMapsData sharedInstance];
        [self setupOverlay];
    }
    
    if (self.navigationController) {
        self.navigationItem.rightBarButtonItem = [[MKUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];
    }
    
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
            if (placeMark) {
                self.place.location = placeMark.location;
                [self zoomToPlace];
            }
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
    [self.mapView addOverlay:overlay
                       level:MKOverlayLevelAboveLabels];
    
    //make sure nothing gets rendered under the osm tiles
    self.mapView.showsBuildings = NO;
    self.mapView.showsPointsOfInterest = NO;
    
    //this looks weird so disable it
    self.mapView.pitchEnabled = NO;
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

@end
