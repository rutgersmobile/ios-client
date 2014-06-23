//
//  www.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/15/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "www.h"
#import "RUChannelManager.h"
#import <TOActivityChrome.h>
#import <TOActivitySafari.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import <Twitter/Twitter.h>
#import "UIImage+Icons.h"


@interface www () <UIWebViewDelegate, UIPopoverControllerDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>
@property (nonatomic,strong) UIPopoverController *sharingPopoverController;

@property NSURLRequest *urlRequest;
@property UIWebView *webView;
@property BOOL getsTitleFromWebPage;

@property (nonatomic,strong) UIBarButtonItem *reloadStopButton;
@property (nonatomic,strong) UIBarButtonItem *actionButton;

@property (nonatomic,strong) UIImage *reloadIcon;
@property (nonatomic,strong) UIImage *stopIcon;

@end

@implementation www

+(NSCache *)storedChannels{
    static NSCache * storedChannels = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        storedChannels = [[NSCache alloc] init];
        storedChannels.countLimit = 6;
    });
    return storedChannels;
}

+(NSURL *)urlForChannel:(NSDictionary *)shortcut{
    return [NSURL URLWithString:shortcut[@"url"]];
}

+(instancetype)componentForChannel:(NSDictionary *)channel{
    NSURL *url = [self urlForChannel:channel];
    if ([self.storedChannels objectForKey:url]) return [self.storedChannels objectForKey:url];
    else {
        //TOWebViewController *webBrowser = [[TOWebViewController alloc] initWithURL:url];
        www *webBrowser = [[www alloc] initWithURLRequest:[[NSURLRequest alloc] initWithURL:url]];
        [self.storedChannels setObject:webBrowser forKey:url];
        return webBrowser;
    }
}

-(id)initWithURLRequest:(NSURLRequest *)urlRequest{
    self = [super init];
    if (self) {
        self.urlRequest = urlRequest;
    }
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    [self setupButtons];
    self.webView = [[UIWebView alloc] initForAutoLayout];
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    [self.webView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    [self.webView loadRequest:self.urlRequest];
}

-(void)setupButtons{
    self.reloadIcon = [UIImage refreshButtonIcon];
    self.stopIcon   = [UIImage stopButtonIcon];

    self.reloadStopButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadStopButtonTapped:)];
    
    self.actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonTapped:)];
   
    self.navigationItem.rightBarButtonItems = @[self.actionButton,self.reloadStopButton];
}

- (void)reloadStopButtonTapped:(id)sender
{
    if (self.webView.isLoading)
        [self.webView stopLoading];
    else
        [self.webView reload];
    
}

-(void)actionButtonTapped:(id)sender{
    NSArray *browserActivities = @[[TOActivitySafari new], [TOActivityChrome new]];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[self.urlRequest.URL] applicationActivities:browserActivities];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        //If we're on an iPhone, we can just present it modally
        [self presentViewController:activityViewController animated:YES completion:nil];
    }
    else
    {
        //UIPopoverController requires we retain our own instance of it.
        //So if we somehow have a prior instance, clean it out
        if (self.sharingPopoverController)
        {
            [self.sharingPopoverController dismissPopoverAnimated:NO];
            self.sharingPopoverController = nil;
        }
        
        //Create the sharing popover controller
        self.sharingPopoverController = [[UIPopoverController alloc] initWithContentViewController:activityViewController];
        self.sharingPopoverController.delegate = self;
        [self.sharingPopoverController presentPopoverFromBarButtonItem:self.actionButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        self.sharingPopoverController.passthroughViews = nil;
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    //Once the popover controller is dismissed, we can release our own reference to it
    self.sharingPopoverController = nil;
}

- (void)copyURLToClipboard
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.urlRequest.URL.absoluteString;
}

- (void)openInBrowser
{
    BOOL chromeIsInstalled = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"googlechrome://"]];
    NSURL *inputURL = self.webView.request.URL;
    
    if (chromeIsInstalled)
    {
        NSString *scheme = inputURL.scheme;
        
        // Replace the URL Scheme with the Chrome equivalent.
        NSString *chromeScheme = nil;
        if ([scheme isEqualToString:@"http"])
        {
            chromeScheme = @"googlechrome";
        }
        else if ([scheme isEqualToString:@"https"])
        {
            chromeScheme = @"googlechromes";
        }
        
        // Proceed only if a valid Google Chrome URI Scheme is available.
        if (chromeScheme)
        {
            NSString *absoluteString    = [inputURL absoluteString];
            NSRange rangeForScheme      = [absoluteString rangeOfString:@":"];
            NSString *urlNoScheme       = [absoluteString substringFromIndex:rangeForScheme.location];
            NSString *chromeURLString   = [chromeScheme stringByAppendingString:urlNoScheme];
            NSURL *chromeURL            = [NSURL URLWithString:chromeURLString];
            
            // Open the URL with Chrome.
            [[UIApplication sharedApplication] openURL:chromeURL];
            
            return;
        }
    }
    
    //If all else fails (Or Chrome is simply not installed), open as per usual
    [[UIApplication sharedApplication] openURL:inputURL];
}

- (void)openMailDialog
{
    MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
    mailViewController.mailComposeDelegate = self;
    [mailViewController setMessageBody:[self.urlRequest.URL absoluteString] isHTML:NO];
    [self presentViewController:mailViewController animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)openMessageDialog
{
    MFMessageComposeViewController *messageViewController = [[MFMessageComposeViewController alloc] init];
    messageViewController.messageComposeDelegate = self;
    [messageViewController setBody:[self.urlRequest.URL absoluteString]];
    [self presentViewController:messageViewController animated:YES completion:nil];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)openTwitterDialog
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    TWTweetComposeViewController *tweetComposer = [[TWTweetComposeViewController alloc] init];
    [tweetComposer addURL:self.urlRequest.URL];
    [self presentViewController:tweetComposer animated:YES completion:nil];
#pragma clang diagnostic pop
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        www *webViewController = [[www alloc] initWithURLRequest:request];
        webViewController.getsTitleFromWebPage = YES;
        [self.navigationController pushViewController:webViewController animated:YES];
        return NO;
    } else {
        return YES;
    }
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    if (self.getsTitleFromWebPage) {
        self.title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    }
}

@end



