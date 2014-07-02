//
//  RUOperatingStatusViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/25/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUOperatingStatusViewController.h"

@interface RUOperatingStatusViewController () <UIWebViewDelegate>
@property UIWebView *webView;
@end

@implementation RUOperatingStatusViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.webView = [[UIWebView alloc] initForAutoLayout];
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    [self.webView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    [self.webView loadRequest:[[NSURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:@"http://halflife.rutgers.edu/ec/notices.php"]]];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    NSString *setTextSizeRule = [NSString stringWithFormat:@"document.body.style.fontSize = %d;", 15];
    [webView stringByEvaluatingJavaScriptFromString:setTextSizeRule];
    self.webView.backgroundColor = [self webViewPageBackgroundColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIColor *)webViewPageBackgroundColor
{
    //Pull the current background colour from the web view
    NSString *rgbString = [self.webView stringByEvaluatingJavaScriptFromString:@"window.getComputedStyle(document.body,null).getPropertyValue('background-color');"];
    
    //if it wasn't found, or if it isn't a proper rgb value, just return white as the default
    if ([rgbString length] == 0 || [rgbString rangeOfString:@"rgb"].location == NSNotFound)
        return [UIColor whiteColor];
    
    //Assuming now the input is either 'rgb(255, 0, 0)' or 'rgba(255, 0, 0, 255)'
    
    //remove the 'rgba' componenet
    rgbString = [rgbString stringByReplacingOccurrencesOfString:@"rgba" withString:@""];
    //conversely, remove the 'rgb' component
    rgbString = [rgbString stringByReplacingOccurrencesOfString:@"rgb" withString:@""];
    //remove the brackets
    rgbString = [rgbString stringByReplacingOccurrencesOfString:@"(" withString:@""];
    rgbString = [rgbString stringByReplacingOccurrencesOfString:@")" withString:@""];
    //remove all spaces
    rgbString = [rgbString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    //we should now have something like '0,0,0'. Split it up via the commas
    NSArray *componenets = [rgbString componentsSeparatedByString:@","];
    
    //Final output componenets
    CGFloat red, green, blue, alpha = 1.0f;
    
    //if the alpha value is 0, this indicates the RGB value wasn't actually set in the page, so just return white
    if ([componenets count] < 3 || ([componenets count] >= 4 && [[componenets objectAtIndex:3] integerValue] == 0))
        return [UIColor whiteColor];
    
    red     = (CGFloat)[[componenets objectAtIndex:0] integerValue] / 255.0f;
    green   = (CGFloat)[[componenets objectAtIndex:1] integerValue] / 255.0f;
    blue    = (CGFloat)[[componenets objectAtIndex:2] integerValue] / 255.0f;
    
    if ([componenets count] >= 4)
        alpha = (CGFloat)[[componenets objectAtIndex:3] integerValue] / 255.0f;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
