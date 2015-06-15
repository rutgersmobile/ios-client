//
//  RUPlace.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/9/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUPlace.h"
#import <AddressBookUI/AddressBookUI.h>

@implementation RUPlace
-(instancetype)initWithDictionary:(NSDictionary *)dictionary{
    self = [super init];
    if (self) {
        self.title = stripString(dictionary[@"title"]);
        self.buildingNumber = stripString(dictionary[@"building_number"]);
        self.campus = stripString(dictionary[@"campus_name"]);
        self.address = [self parseAddressDictionary:dictionary[@"location"]];
        self.location = [self parseLocationDictionary:dictionary[@"location"]];
        self.offices = dictionary[@"offices"];
        self.buildingCode = stripString(dictionary[@"building_code"]);
        self.descriptionString = stripString([dictionary[@"description"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]);
        self.uniqueID = stripString(dictionary[@"id"]);
    }
    return self;
}

-(instancetype)initWithTitle:(NSString *)title addressString:(NSString *)addressString{
    self = [super init];
    if (self) {
        self.title = title;
        self.addressString = addressString;
    }
    return self;
}

-(NSString *)description{
    return [NSString stringWithFormat:@"%@ - %@",self.buildingNumber,self.title];
}

-(CLLocation *)parseLocationDictionary:(NSDictionary *)locationDictionary{
    if (!(locationDictionary[@"latitude"] && locationDictionary[@"longitude"])) return nil;
    
    CLLocationDegrees latitude = [locationDictionary[@"latitude"] doubleValue];
    CLLocationDegrees longitude = [locationDictionary[@"longitude"] doubleValue];
    
    if (latitude == 0 && longitude == 0) return nil;
    
    return [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
}

-(NSDictionary *)parseAddressDictionary:(NSDictionary *)addressDictionary{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    NSDictionary *mapping = @{(__bridge NSString *)kABPersonAddressStreetKey : @"street",
                              (__bridge NSString *)kABPersonAddressCityKey : @"city",
                              (__bridge NSString *)kABPersonAddressStateKey : @"state",
                              (__bridge NSString *)kABPersonAddressZIPKey : @"postal_code",
                              };
    
    [mapping enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *strippedString = stripString(addressDictionary[obj]);
        if (strippedString) {
            dictionary[key] = strippedString;
        }
    }];
    
    if (!dictionary.count) return nil;
    return dictionary;
}

NSString *stripString(NSString *string){
    return ![string isEqualToString:@""] ? string : nil;
}

-(CLLocationCoordinate2D)coordinate{
    return self.location.coordinate;
}
@end
