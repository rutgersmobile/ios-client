//
//  RUMapView.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/2/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUMapView.h"
#import "RUMapsTileOverlay.h"

@implementation RUMapView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //add our overlay
        RUMapsTileOverlay *overlay = [[RUMapsTileOverlay alloc] init];
        [self addOverlay:overlay
                           level:MKOverlayLevelAboveLabels];
        
        //make sure nothing gets rendered under the osm tiles
        self.showsBuildings = NO;
        self.showsPointsOfInterest = NO;
        
        //this looks weird so disable it
        self.pitchEnabled = NO;
        self.showsUserLocation = YES;
        
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
