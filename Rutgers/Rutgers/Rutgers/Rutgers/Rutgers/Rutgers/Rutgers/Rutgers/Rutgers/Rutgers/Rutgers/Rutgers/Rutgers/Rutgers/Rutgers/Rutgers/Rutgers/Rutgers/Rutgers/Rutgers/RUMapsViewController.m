//
//  RUMapsViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/8/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUPlace.h"
#import <MapKit/MapKit.h>
#import "RUMapsTileOverlay.h"
#import "RUMapsData.h"
#import <AFNetworking.h>
#import <AFURLResponseSerialization.h>
#import "RUOSMDataLoadingManager.h"

@import Mapbox;

#define DEFAULT_MAP_RECT

@interface RUMapsViewController ()<MKMapViewDelegate, MGLMapViewDelegate>
//@property RUMapsData *mapsData;
@property (nonatomic) MKMapView *mkMapView;
@property (nonatomic) MGLMapView *mglMapView ;
@property BOOL usesMapBox;
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


MGLCoordinateBounds  MGLCoordinateBoundsFromMapRect(MKMapRect rect){
    MKMapPoint nep  = MKMapPointMake(rect.origin.x + rect.size.width , rect.origin.y );
    CLLocationCoordinate2D ne = MKCoordinateForMapPoint(nep);
    
    MKMapPoint swp = MKMapPointMake(rect.origin.x , rect.origin.y + rect.size.height);
    CLLocationCoordinate2D sw = MKCoordinateForMapPoint(swp);
    
    return MGLCoordinateBoundsMake(sw, ne);
}

-(void)loadView{
    [super loadView];
    if (self.usesMapBox) {
        self.mglMapView = [[MGLMapView alloc] initWithFrame:self.view.bounds];
        self.mglMapView.delegate = self;
        self.mglMapView.opaque = YES;
        self.mglMapView.showsUserLocation = YES;
    
        self.view = self.mglMapView;
        [self.mglMapView setVisibleCoordinateBounds: MGLCoordinateBoundsFromMapRect(DEFAULT_MAP_RECT)];
        
    } else {
        self.mkMapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
        self.mkMapView.delegate = self;
        self.mkMapView.opaque = YES;
        self.mkMapView.showsUserLocation = YES;
        
        
        self.view = self.mkMapView;
        [self.mkMapView setVisibleMapRect:DEFAULT_MAP_RECT];
    }

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[RUOSMDataLoadingManager sharedManager] get];

    // Do any additional setup after loading the view.
   
   // self.usesOSM = YES;
    
    if (self.usesMapBox) {
        [self setupOverlay];
    }
    
    if (self.navigationController) {
        if(self.usesMapBox){
        //    self.navigationItem.rightBarButtonItem = [[MGLUserTackingBar]]
            NSLog(@"mgl map view");
        } else {
             self.navigationItem.rightBarButtonItem = [[MKUserTrackingBarButtonItem alloc] initWithMapView:self.mkMapView];

        }
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
