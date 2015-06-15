//
//  RUPlace.h
//  Rutgers
//
//  Created by Kyle Bailey on 6/9/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface RUPlace : NSObject <MKAnnotation>
-(instancetype)initWithDictionary:(NSDictionary *)dictionary NS_DESIGNATED_INITIALIZER;
-(instancetype)initWithTitle:(NSString *)title addressString:(NSString *)addressString NS_DESIGNATED_INITIALIZER;

@property (nonatomic, copy) NSString *title;
@property (nonatomic) NSString *buildingNumber;
@property (nonatomic) NSString *campus;
@property (nonatomic) NSDictionary *address;
@property (nonatomic) NSString *addressString;
@property (nonatomic) NSArray *offices;
@property (nonatomic) NSString *buildingCode;
@property (nonatomic) NSString *descriptionString;
@property (nonatomic) NSString *uniqueID;
@property (nonatomic) CLLocation *location;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@end
