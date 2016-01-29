//
//  RUDefines.h
//  Rutgers
//
//  Created by Open Systems Solutions on 9/21/15.
//  Copyright © 2015 Rutgers. All rights reserved.
//

#ifndef RUDefines_h
#define RUDefines_h

#define kLabelHorizontalInsets      15.0f
#define kLabelVerticalInsets        11.0f

#define kLabelHorizontalInsetsSmall      8.0f
#define kLabelVerticalInsetsSmall        5.0f

#define IPAD_SCALE 1.15

#define ASSERT_MAIN_THREAD NSAssert([NSThread isMainThread], @"This method must be called on the main thread")

extern uint64_t dispatch_benchmark(size_t count, void (^block)(void));

static inline NSComparisonResult compare(NSInteger int1, NSInteger int2){
    if (int1 < int2) return NSOrderedAscending;
    if (int1 > int2) return NSOrderedDescending;
    return NSOrderedSame;
};

NSString *stringEscapeFunction(NSString *component) {
    return [[component lowercaseString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

extern BOOL iPad();

static NSString *const gittag = @"4.0";

static NSString *const api = @"1";

typedef NS_ENUM(NSUInteger, BetaMode) {
    BetaModeDevelopment,
    BetaModeBeta,
    BetaModeProduction
};

static BetaMode const betaMode = BetaModeBeta;

extern BOOL isBeta();

extern NSString * betaModeString();

#endif /* RUDefines_h */
