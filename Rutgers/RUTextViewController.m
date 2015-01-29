//
//  text.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/15/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUTextViewController.h"
#import "ALTableViewTextCell.h"
#import <NSString+HTML.h>
#import "NSAttributedString+FromHTML.h"

@interface RUTextViewController ()
@property (nonatomic) NSString *data;
@property (nonatomic) BOOL centersText;
@end

@implementation RUTextViewController
+(instancetype)channelWithConfiguration:(NSDictionary *)channel{
    return [[RUTextViewController alloc] initWithChannel:channel];
}

-(id)initWithChannel:(NSDictionary *)channel{
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        self.data = channel[@"data"];
        self.centersText = [channel[@"centersText"] boolValue];
    }
    return self;
}

-(void)loadView{
    [super loadView];
    self.textView = [UITextView newAutoLayoutView];
    self.textView.translatesAutoresizingMaskIntoConstraints = NO;
    self.textView.editable = NO;
    self.textView.selectable = NO;
    self.textView.textContainerInset = UIEdgeInsetsMake(kLabelVerticalInsets, kLabelHorizontalInsetsSmall, kLabelVerticalInsets, kLabelHorizontalInsetsSmall);
    self.textView.alwaysBounceVertical = YES;
    
    [self.view addSubview:self.textView];
    [self.textView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadText) name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    [self loadText];
}

-(void)loadText{
    NSMutableAttributedString *attributedText = [NSMutableAttributedString attributedStringFromHTMLString:[self.data stringWithNewLinesAsBRs] preferedTextStyle:UIFontTextStyleBody];
    if (self.centersText) {
        [attributedText enumerateAttributesInRange:NSMakeRange(0, attributedText.length) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
            NSMutableParagraphStyle *paragraphStyle = [attrs[NSParagraphStyleAttributeName] mutableCopy];
            paragraphStyle.alignment = NSTextAlignmentCenter;
            [attributedText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
        }];
    }
    
    self.textView.attributedText = attributedText;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
}
@end
