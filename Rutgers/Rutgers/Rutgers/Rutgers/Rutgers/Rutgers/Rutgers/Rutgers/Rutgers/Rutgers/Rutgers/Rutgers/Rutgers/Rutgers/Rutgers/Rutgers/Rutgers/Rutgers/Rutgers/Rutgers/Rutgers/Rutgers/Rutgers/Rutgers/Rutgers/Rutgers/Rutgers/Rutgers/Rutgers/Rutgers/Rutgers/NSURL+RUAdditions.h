//
//  NSURL+RUAdditions.h
//  Rutgers
//
//  Created by Open Systems Solutions on 1/5/16.
//  Copyright © 2016 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (RUAdditions)
+(NSURL *)rutgersUrlWithPathComponents:(NSArray <NSString *>*)pathComponents;
-(NSURL *)asRutgersURL;
-(NSURL *)asHTTPURL;
@end

@interface NSString (RUAdditions)
-(NSString *)rutgersStringEscape;
@end