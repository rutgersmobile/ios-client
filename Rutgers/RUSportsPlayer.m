//
//  RUSportsPlayer.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/13/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUSportsPlayer.h"
#import <XMLDictionary.h>
#import "NSAttributedString+FromHTML.h"

@interface RUSportsPlayer ()
@property (nonatomic) NSString *bioString;
@end

@implementation RUSportsPlayer

-(instancetype)initWithDictionary:(NSDictionary *)dictionary{
    self = [self init];
    if (self) {
        [self parseName:[dictionary[@"fullName"] firstObject]];
        [self parseImageURL:[dictionary[@"image"] firstObject]];
        [self parseJerseyNumber:[dictionary[@"jerseyNumber"] firstObject]];
        [self parsePositionString:[dictionary[@"position"] firstObject]];
     
        self.physique = [dictionary[@"physique"] firstObject];
        self.hometown = [dictionary[@"hometown"] firstObject];
        self.bioString = [dictionary[@"bio"] firstObject];
    }
    return self;
}

-(NSAttributedString *)bio{
    if (!_bio && self.bioString) {
        
        NSMutableAttributedString *string = [NSMutableAttributedString attributedStringFromHTMLString:self.bioString];
        [string enumerateAttribute:NSFontAttributeName inRange:NSMakeRange(0, string.length) options:0 usingBlock:^(UIFont *font, NSRange range, BOOL *stop) {
            BOOL bold = [[font description] rangeOfString:@"bold"].location != NSNotFound;
            [string setAttributes:@{NSFontAttributeName : [UIFont preferredFontForTextStyle:bold ? UIFontTextStyleCaption1 : UIFontTextStyleCaption2]} range:range];
        }];
        _bio = string;
        
    }
    return _bio;
}

-(void)parsePositionString:(NSString *)postionString{
    NSArray *strings = [postionString componentsSeparatedByString:@", "];
    
    NSString *pos = [strings firstObject];
    NSString *class = [strings lastObject];
    
    pos = [[pos componentsSeparatedByString:@":"] lastObject];
    class = [[class componentsSeparatedByString:@":"] lastObject];
    
    self.position = pos;
    self.className = class;
}

-(void)parseName:(NSString *)name{
    self.name = [name stringByReplacingOccurrencesOfString:@"  " withString:@" "];
    
    NSArray *nameComponents = [self.name componentsSeparatedByString:@" "];
    
    NSString *firstName = [nameComponents firstObject];
    NSString *lastName = [nameComponents lastObject];
    
    NSString *firstInitial = [firstName substringToIndex:1];
    NSString *lastInitial = [lastName substringToIndex:1];
    
    self.initials = [NSString stringWithFormat:@"%@%@",firstInitial,lastInitial];
}

-(void)parseImageURL:(NSString *)imageURL{
    if ([imageURL rangeOfString:@"blockr.jpg"].location == NSNotFound) {
        self.imageURL = [NSURL URLWithString:imageURL];
    }
}

-(void)parseJerseyNumber:(NSString *)jerseyNumber{
    self.jerseyNumber = [jerseyNumber stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"#"]];
}

@end
