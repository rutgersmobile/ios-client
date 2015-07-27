//
//  RUNewWebViewController.m
//  Rutgers
//
//  Created by Open Systems Solutions on 7/8/15.
//  Copyright (c) 2015 Rutgers. All rights reserved.
//

#import "RUNewWebViewController.h"
#import <WebKit/WebKit.h>
#import <PureLayout.h>
#import "RUWebView.h"
#import <UIImage+TOWebViewControllerIcons.h>
#import "NSObject+KVOBlock.h"

@interface RUNewWebViewController () <UIPopoverControllerDelegate>
@property (nonatomic) RUWebView *webView;
@property (nonatomic) NSDictionary *channel;
@property (nonatomic) UIPopoverController *sharingPopoverController;

@property (nonatomic,strong) UIButton *backButton;                       /* Moves the web view one page back */
@property (nonatomic,strong) UIButton *forwardButton;                    /* Moves the web view one page forward */
@property (nonatomic,strong) UIButton *reloadStopButton;                 /* Reload / Stop buttons */
@property (nonatomic,strong) UIButton *actionButton;                     /* Shows the UIActivityViewController */

@property (nonatomic,strong) UIImage *reloadIcon;
@property (nonatomic,strong) UIImage *stopIcon;

@property (nonatomic) UIProgressView *progressView;
@property (nonatomic) id observer;
@end

#define BLANK_BARBUTTONITEM [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]

/* Navigation Bar Properties */
#define NAVIGATION_BUTTON_WIDTH             31
#define NAVIGATION_BUTTON_SIZE              CGSizeMake(31,31)
#define NAVIGATION_BUTTON_SPACING           40
#define NAVIGATION_BUTTON_SPACING_IPAD      20
#define NAVIGATION_BAR_HEIGHT               (64.0f)
#define NAVIGATION_TOGGLE_ANIM_TIME         0.3

@implementation RUNewWebViewController

//Global cache holding RUWebViewController objects
+(NSCache *)storedChannels{
    static NSCache * storedChannels = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        storedChannels = [[NSCache alloc] init];
        storedChannels.countLimit = 5;
    });
    return storedChannels;
}

+(RUNewWebViewController *)newWithChannel:(NSDictionary *)channel{
    return [[self alloc] initWithChannel:channel];
}

-(instancetype)initWithChannel:(NSDictionary *)channel{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.channel = channel;
    }
    return self;
}

-(void)loadView{
    [super loadView];
    self.webView = [[RUWebView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.webView];
    [self.webView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    [self.view addSubview:self.progressView];
    [self.progressView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
    [self.progressView autoPinEdgeToSuperviewEdge:ALEdgeRight];
    [self.progressView autoPinEdgeToSuperviewMargin:ALEdgeTop];
}

-(void)viewDidLoad{
    [super viewDidLoad];
 
    NSURL *url = [NSURL URLWithString:self.channel[@"url"]];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    
    //only load the buttons if we need to
    if (self.navigationButtonsHidden == NO)
        [self setUpNavigationButtons];
    
    
    //Set the appropriate actions to the buttons
    [self.backButton        addTarget:self action:@selector(backButtonTapped:)          forControlEvents:UIControlEventTouchUpInside];
    [self.forwardButton     addTarget:self action:@selector(forwardButtonTapped:)       forControlEvents:UIControlEventTouchUpInside];
    [self.reloadStopButton  addTarget:self action:@selector(reloadStopButtonTapped:)    forControlEvents:UIControlEventTouchUpInside];
    [self.actionButton      addTarget:self action:@selector(actionButtonTapped:)        forControlEvents:UIControlEventTouchUpInside];
    
    UIProgressView *progressView = self.progressView;
    self.observer = [self.webView aapl_addObserverForKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew withBlock:^(id obj, NSDictionary *change, id observer) {
        [progressView setProgress:[change[NSKeyValueChangeNewKey] floatValue] animated:YES];
    }];
}

-(void)dealloc{
    [self.progressView aapl_removeObserver:self.observer];
}

- (void)setUpNavigationButtons
{
    //set up the buttons for the navigation bar
    CGRect buttonFrame = CGRectZero; buttonFrame.size = NAVIGATION_BUTTON_SIZE;
    
    UIButtonType buttonType = UIButtonTypeSystem;
    
    //set up the back button
    UIImage *backButtonImage = [UIImage TOWebViewControllerIcon_backButtonWithAttributes:self.buttonThemeAttributes];
    if (self.backButton == nil) {
        self.backButton = [UIButton buttonWithType:buttonType];
        [self.backButton setFrame:buttonFrame];
        [self.backButton setShowsTouchWhenHighlighted:YES];
    }
    [self.backButton setImage:backButtonImage forState:UIControlStateNormal];
    
    //set up the forward button (Don't worry about the frame at this point as it will be hidden by default)
    UIImage *forwardButtonImage = [UIImage TOWebViewControllerIcon_forwardButtonWithAttributes:self.buttonThemeAttributes];
    if (self.forwardButton == nil) {
        self.forwardButton  = [UIButton buttonWithType:buttonType];
        [self.forwardButton setFrame:buttonFrame];
        [self.forwardButton setShowsTouchWhenHighlighted:YES];
    }
    [self.forwardButton setImage:forwardButtonImage forState:UIControlStateNormal];
    
    //set up the reload button
    if (self.reloadStopButton == nil) {
        self.reloadStopButton = [UIButton buttonWithType:buttonType];
        [self.reloadStopButton setFrame:buttonFrame];
        [self.reloadStopButton setShowsTouchWhenHighlighted:YES];
    }
    
    self.reloadIcon = [UIImage TOWebViewControllerIcon_refreshButtonWithAttributes:self.buttonThemeAttributes];
    self.stopIcon   = [UIImage TOWebViewControllerIcon_stopButtonWithAttributes:self.buttonThemeAttributes];
    [self.reloadStopButton setImage:self.reloadIcon forState:UIControlStateNormal];
    
    //if desired, show the action button
    if (self.showActionButton) {
        if (self.actionButton == nil) {
            self.actionButton = [UIButton buttonWithType:buttonType];
            [self.actionButton setFrame:buttonFrame];
            [self.actionButton setShowsTouchWhenHighlighted:YES];
        }
        
        [self.actionButton setImage:[UIImage TOWebViewControllerIcon_actionButtonWithAttributes:self.buttonThemeAttributes] forState:UIControlStateNormal];
    }
}


#pragma mark -
#pragma mark Button Callbacks
- (void)backButtonTapped:(id)sender
{
    [self.webView goBack];
    [self refreshButtonsState];
}

- (void)forwardButtonTapped:(id)sender
{
    [self.webView goForward];
    [self refreshButtonsState];
}

- (void)reloadStopButtonTapped:(id)sender
{
    //regardless of reloading, or stopping, halt the webview
    [self.webView stopLoading];
    
    if (self.webView.isLoading) {
       
    } else {
        [self.webView reload];
    }
    
    //refresh the buttons
    [self refreshButtonsState];
}

#pragma mark -
#pragma mark Action Item Event Handlers
- (void)actionButtonTapped:(id)sender
{
    //NSArray *browserActivities = @[[TOActivitySafari new], [TOActivityChrome new]];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[self.webView.URL] applicationActivities:nil];
    
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
        [self.sharingPopoverController presentPopoverFromRect:self.actionButton.frame inView:self.actionButton.superview permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    //Once the popover controller is dismissed, we can release our own reference to it
    self.sharingPopoverController = nil;
}

#pragma mark -
/*
#pragma mark Page Load Progress Tracking Handlers
- (void)resetLoadProgress
{
    memset(&_loadingProgressState, 0, sizeof(_loadingProgressState));
    [self setLoadingProgress:0.0f];
}

- (void)startLoadProgress
{
    if (self.webView.isLoading == NO)
        return;
    
    //If we haven't started loading yet, set the progress to small, but visible value
    if (_loadingProgressState.loadingProgress < kInitialProgressValue)
    {
        //reset the loading bar
        CGRect frame = self.loadingBarView.frame;
        frame.size.width = CGRectGetWidth(self.view.bounds);
        frame.origin.x = -frame.size.width;
        frame.origin.y = self.webView.scrollView.contentInset.top;
        self.loadingBarView.frame = frame;
        self.loadingBarView.alpha = 1.0f;
        
        //add the loading bar to the view
        if (self.showLoadingBar)
            [self.view insertSubview:self.loadingBarView aboveSubview:self.navigationBar];
        
        //kickstart the loading progress
        [self setLoadingProgress:kInitialProgressValue];
        
        //show that loading started in the status bar
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        //set the title to the URL until we load the page properly
        if (self.showPageTitles && self.showUrlWhileLoading) {
            NSString *url = [self.url absoluteString];
            url = [url stringByReplacingOccurrencesOfString:@"http://" withString:@""];
            url = [url stringByReplacingOccurrencesOfString:@"https://" withString:@""];
            self.title = url;
        }
        
        if (self.reloadStopButton)
            [self.reloadStopButton setImage:self.stopIcon forState:UIControlStateNormal];
    }
}

- (void)incrementLoadProgress
{
    float progress          = _loadingProgressState.loadingProgress;
    float maxProgress       = _loadingProgressState.interactive ? kAfterInteractiveMaxProgressValue : kBeforeInteractiveMaxProgressValue;
    float remainingPercent  = (float)_loadingProgressState.loadingCount / (float)_loadingProgressState.maxLoadCount;
    float increment         = (maxProgress - progress) * remainingPercent;
    progress                = fmin((progress+increment), maxProgress);
    
    [self setLoadingProgress:progress];
}

- (void)finishLoadProgress
{
    //reset the load progress
    [self refreshButtonsState];
    [self setLoadingProgress:1.0f];
    
    //in case it didn't succeed yet, try setting the page title again
    if (self.showPageTitles)
        self.title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    if (self.reloadStopButton)
        [self.reloadStopButton setImage:self.reloadIcon forState:UIControlStateNormal];
}

- (void)setLoadingProgress:(CGFloat)loadingProgress
{
    // progress should be incremental only
    if (loadingProgress > _loadingProgressState.loadingProgress)
    {
        _loadingProgressState.loadingProgress = loadingProgress;
        
        //Update the loading bar progress to match
        if (self.showLoadingBar)
        {
            CGRect frame = self.loadingBarView.frame;
            frame.origin.x = -CGRectGetWidth(self.loadingBarView.frame) + (CGRectGetWidth(self.view.bounds) * _loadingProgressState.loadingProgress);
            
            [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.loadingBarView.frame = frame;
            } completion:^(BOOL finished) {
                //once loading is complete, fade it out
                if (loadingProgress >= 1.0f - FLT_EPSILON)
                {
                    [UIView animateWithDuration:0.2f animations:^{
                        self.loadingBarView.alpha = 0.0f;
                    }];
                }
            }];
        }
    }
    else if (loadingProgress == 0)
    {
        _loadingProgressState.loadingProgress = loadingProgress;
        if (self.showLoadingBar)
        {
            CGRect frame = self.loadingBarView.frame;
            frame.origin.x = -CGRectGetWidth(self.loadingBarView.frame);
            self.loadingBarView.frame = frame;
        }
    }
}

- (void)handleLoadRequestCompletion
{
    //decrement the number of concurrent requests
    _loadingProgressState.loadingCount--;
    
    //update the progress bar
    [self incrementLoadProgress];
    
    //Query the webview to see what load state JavaScript perceives it at
    NSString *readyState = [self.webView stringByEvaluatingJavaScriptFromString:@"document.readyState"];
    
    //interactive means the page has loaded sufficiently to allow user interaction now
    BOOL interactive = [readyState isEqualToString:@"interactive"];
    if (interactive)
    {
        _loadingProgressState.interactive = YES;
        
        //if we're at the interactive state, attach a Javascript listener to inform us when the page has fully loaded
        NSString *waitForCompleteJS = [NSString stringWithFormat:   @"window.addEventListener('load',function() { "
                                       @"var iframe = document.createElement('iframe');"
                                       @"iframe.style.display = 'none';"
                                       @"iframe.src = '%@';"
                                       @"document.body.appendChild(iframe);"
                                       @"}, false);", kCompleteRPCURL];
        
        [self.webView stringByEvaluatingJavaScriptFromString:waitForCompleteJS];
        
        //see if we can set the proper page title yet
        if (self.showPageTitles)
            self.title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
        
        //if we're matching the view BG to the web view, update the background colour now
        if (self.hideWebViewBoundaries)
            self.view.backgroundColor = [self webViewPageBackgroundColor];
        
        //finally, if the app desires it, disable the ability to tap and hold on links
        if (self.disableContextualPopupMenu)
            [self.webView stringByEvaluatingJavaScriptFromString:@"document.body.style.webkitTouchCallout='none';"];
    }
    
    BOOL isNotRedirect = self.url && [self.url isEqual:self.webView.request.URL];
    BOOL complete = [readyState isEqualToString:@"complete"];
    if (complete && isNotRedirect)
        [self finishLoadProgress];
}*/

#pragma mark -
#pragma mark Button State Handling
- (void)refreshButtonsState
{
    //update the state for the back button
    if (self.webView.canGoBack)
        [self.backButton setEnabled:YES];
    else
        [self.backButton setEnabled:NO];
    
    if (self.webView.canGoForward)
        [self.forwardButton setEnabled:YES];
    else
        [self.forwardButton setEnabled:NO];
    
    if (self.webView.isLoading) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [self.reloadStopButton setImage:self.stopIcon forState:UIControlStateNormal];
    }
    else {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self.reloadStopButton setImage:self.reloadIcon forState:UIControlStateNormal];
    }
}
    
@end

