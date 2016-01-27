//
//  RUFavorite.m
//  Rutgers
//
//  Created by Open Systems Solutions on 1/14/16.
//  Copyright © 2016 Rutgers. All rights reserved.
//

#import "RUFavorite.h"

@implementation RUFavorite

-(instancetype)initWithTitle:(NSString *)title handle:(NSString *)channelHandle url:(NSURL *)deepLinkingUrl{
    self = [super init];
    if (self) {
        _title = title;
        _channelHandle = channelHandle;
        _deepLinkingUrl = deepLinkingUrl;
    }
    return self;
}

-(instancetype)initWithDictionary:(NSDictionary *)dictionary{
    self = [super init];
    if (self) {
        _title = dictionary[@"title"];
        _channelHandle = dictionary[@"handle"];
        _deepLinkingUrl = [NSURL URLWithString:dictionary[@"url"]];
    }
    return self;
}

-(NSDictionary *)dictionaryRepresentation{
    return @{
             @"title" : self.title,
             @"handle" : self.channelHandle,
             @"url" : self.deepLinkingUrl.absoluteString
             };
}

-(BOOL)isEqual:(id)object{
    if (self == object) return true;
    if (![object isKindOfClass:[self class]]) return false;
    RUFavorite *other = object;
    return [self.title isEqual:other.title] && [self.channelHandle isEqualToString:other.channelHandle] && [self.deepLinkingUrl isEqual:other.deepLinkingUrl];
}

@end
