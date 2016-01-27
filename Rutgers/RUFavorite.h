//
//  RUFavorite.h
//  Rutgers
//
//  Created by Open Systems Solutions on 1/14/16.
//  Copyright © 2016 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RUFavorite : NSObject
@property (nonatomic, readonly) NSString *channelHandle;
@property (nonatomic, readonly) NSURL *deepLinkingUrl;
@property (nonatomic, readonly) NSString *title;

-(instancetype)initWithTitle:(NSString *)title handle:(NSString *)channelHandle url:(NSURL *)deepLinkingUrl;
-(instancetype)initWithDictionary:(NSDictionary *)dictionary;
-(NSDictionary *)dictionaryRepresentation;
@end
