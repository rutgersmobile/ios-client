//
//  RUWKWebViewController.m
//  Rutgers
//
//  Created by Open Systems Solutions on 8/3/15.
//  Copyright (c) 2015 Rutgers. All rights reserved.
//

#import "RUWKWebViewController.h"
#import "UIImage+TOWebViewControllerIcons.h"
#import "NSObject+KVOBlock.h"
#import <PureLayout.h>
#import "NSDictionary+Channel.h"
#import "TOActivitySafari.h"
#import "TOActivityChrome.h"

/* The default blue tint color of iOS 7.0 */
#define DEFAULT_BAR_TINT_COLOR [UIColor colorWithRed:0.0f green:110.0f/255.0f blue:1.0f alpha:1.0f]

/* Blank UIBarButtonItem creation */
#define BLANK_BARBUTTONITEM [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]

/* View Controller Theming Properties */
#define BACKGROUND_COLOR_MINIMAL    [UIColor colorWithRed:0.741f green:0.741 blue:0.76f alpha:1.0f]
#define BACKGROUND_COLOR            (BACKGROUND_COLOR_MINIMAL)

/* Navigation Bar Properties */
#define NAVIGATION_BUTTON_WIDTH             31
#define NAVIGATION_BUTTON_SIZE              CGSizeMake(31,31)
#define NAVIGATION_BUTTON_SPACING           40
#define NAVIGATION_BUTTON_SPACING_IPAD      20
#define NAVIGATION_BAR_HEIGHT               (64)
#define NAVIGATION_TOGGLE_ANIM_TIME         0.3

/* Toolbar Properties */
#define TOOLBAR_HEIGHT      44.0f

/* Hieght of the loading progress bar view */
#define LOADING_BAR_HEIGHT          2

@interface RUWKWebViewController () <WKNavigationDelegate, WKUIDelegate, UIPopoverControllerDelegate>
@property (nonatomic,readonly) BOOL beingPresentedModally;              /* The controller was presented as a modal popup (eg, 'Done' button) */
@property (nonatomic,readonly) BOOL onTopOfNavigationControllerStack;   /* We're in, and not the root of a UINavigationController (eg, 'Back' button)*/

@property (nonatomic,strong, readwrite) WKWebView *webView;                      /* The web view, where all the magic happens */
@property (nonatomic,readonly) UINavigationBar *navigationBar;          /* Navigation bar shown along the top of the view */
@property (nonatomic,readonly) UIToolbar *toolbar;                      /* Toolbar shown along the bottom */
@property (nonatomic,strong) UIProgressView *loadingBarView;        /* The loading bar, displayed when a page is being loaded */

/* Navigation Buttons */
@property (nonatomic,strong) UIButton *backButton;                       /* Moves the web view one page back */
@property (nonatomic,strong) UIButton *forwardButton;                    /* Moves the web view one page forward */
@property (nonatomic,strong) UIButton *reloadStopButton;                 /* Reload / Stop buttons */
@property (nonatomic,strong) UIButton *actionButton;                     /* Shows the UIActivityViewController */
@property (nonatomic,strong) UIView   *buttonsContainerView;              /* The container view that holds all of the navigation buttons. */

/* Button placement metrics */
@property (nonatomic,assign) CGFloat buttonWidth;                        /* The size of each button */
@property (nonatomic,assign) CGFloat buttonSpacing;                      /* The size of the gap between each button */

/* Images for the Reload/Stop button */
@property (nonatomic,strong) UIImage *reloadIcon;
@property (nonatomic,strong) UIImage *stopIcon;

/* Theming attributes for generating navigation button art. */
@property (nonatomic,strong) NSMutableDictionary *buttonThemeAttributes;

@property (nonatomic,strong) UIPopoverController *sharingPopoverController;

/* See if we need to revert the toolbar to 'hidden' when we pop off a navigation controller. */
@property (nonatomic,assign) BOOL hideToolbarOnClose;
/* See if we need to revert the navigation bar to 'hidden' when we pop from a navigation controller */
@property (nonatomic,assign) BOOL hideNavBarOnClose;

/* Perform all common setup steps */
- (void)setup;

- (NSURL *)cleanURL:(NSURL *)url;

/* Init and configure various sections of the controller */
- (void)setUpNavigationButtons;
- (UIView *)containerViewWithNavigationButtons;

/* Review the current state of the web view and update the UI controls in the nav bar to match it */
- (void)refreshButtonsState;

/* Event callbacks for button taps */
- (void)backButtonTapped:(id)sender;
- (void)forwardButtonTapped:(id)sender;
- (void)reloadStopButtonTapped:(id)sender;
- (void)actionButtonTapped:(id)sender;
- (void)doneButtonTapped:(id)sender;

@property (nonatomic) id progressObserver;

@property (nonatomic) NSDictionary *channelConfiguration;
@end

@implementation RUWKWebViewController
+(id)channelWithConfiguration:(NSDictionary *)channel{
    return [[self alloc] initWithChannel:channel];
}

-(instancetype)initWithChannel:(NSDictionary *)channel{
    NSString *urlString = [channel channelURL];
    self = [self initWithURLString:urlString];
    if (self) {
        self.channelConfiguration = channel;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
        [self setup];
    
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
        [self setup];
    
    return self;
}

- (instancetype)initWithURL:(NSURL *)url
{
    if (self = [super init])
        _url = [self cleanURL:url];
    
    return self;
}

- (instancetype)initWithURLString:(NSString *)urlString
{
    return [self initWithURL:[NSURL URLWithString:urlString]];
}

- (NSURL *)cleanURL:(NSURL *)url
{
    //If no URL scheme was supplied, defer back to HTTP.
    if (url.scheme.length == 0) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", [url absoluteString]]];
    }
    
    return url;
}

- (void)setup
{
    //Direct ivar reference since we don't want to trigger their actions yet
    _showActionButton = YES;
    _showDoneButton   = YES;
    _buttonSpacing    = (iPad() == NO) ? NAVIGATION_BUTTON_SPACING : NAVIGATION_BUTTON_SPACING_IPAD;
    _buttonWidth      = NAVIGATION_BUTTON_WIDTH;
    _showLoadingBar   = YES;
    _showUrlWhileLoading = YES;
    _showPageTitles   = YES;
    
    //Set the initial default style as full screen (But this can be easily overridden)
    self.modalPresentationStyle = UIModalPresentationFullScreen;
    
}

-(NSURLRequest *)urlRequest{
    return [NSURLRequest requestWithURL:self.url];
}

- (void)loadView
{
    //Create the all-encompassing container view
    [super loadView];
    self.view.backgroundColor = (self.hideWebViewBoundaries ? [UIColor whiteColor] : BACKGROUND_COLOR);
    self.view.opaque = YES;
    self.view.clipsToBounds = YES;
    
    //Create the web view
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.opaque = YES;

    [self.view addSubview:self.webView];
    
    //Set up the loading bar
    CGFloat y = self.webView.scrollView.contentInset.top;
    self.loadingBarView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, y, CGRectGetWidth(self.view.frame), LOADING_BAR_HEIGHT)];
    self.loadingBarView.trackTintColor = [UIColor clearColor];
    self.loadingBarView.progress = 0;
    
    [self.view addSubview:self.loadingBarView];
    
    [self.loadingBarView autoPinEdgeToSuperviewEdge:ALEdgeLeading];
    [self.loadingBarView autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
    [self.loadingBarView autoPinToTopLayoutGuideOfViewController:self withInset:0];
    
    self.loadingBarView.tintColor = self.loadingBarTintColor;

    //only load the buttons if we need to
    if (self.navigationButtonsHidden == NO)
        [self setUpNavigationButtons];
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


- (UIView *)containerViewWithNavigationButtons
{
    CGRect buttonFrame = CGRectZero;
    buttonFrame.size = NAVIGATION_BUTTON_SIZE;
    
    CGFloat width = (self.buttonWidth*3)+(self.buttonSpacing*2);
    if (self.showActionButton)
        width = (self.buttonWidth*4)+(self.buttonSpacing*3);
    
    //set up the icons for the navigation bar
    UIView *iconsContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, self.buttonWidth)];
    iconsContainerView.backgroundColor = [UIColor clearColor];
    
    //add the back button
    self.backButton.frame = buttonFrame;
    [iconsContainerView addSubview:self.backButton];
    
    //add the forward button too, but keep it hidden for now
    buttonFrame.origin.x = self.buttonWidth + self.buttonSpacing;
    self.forwardButton.frame = buttonFrame;
    [iconsContainerView addSubview:self.forwardButton];
    buttonFrame.origin.x += (self.buttonWidth + self.buttonSpacing);
    
    //add the reload button if the action button is hidden
    self.reloadStopButton.frame = buttonFrame;
    [iconsContainerView addSubview:self.reloadStopButton];
    buttonFrame.origin.x += (self.buttonWidth + self.buttonSpacing);
    
    //add the action button
    if (self.showActionButton) {
        self.actionButton.frame = buttonFrame;
        [iconsContainerView addSubview:self.actionButton];
    }
    
    return iconsContainerView;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.navigationController) {
        self.hideToolbarOnClose = self.navigationController.toolbarHidden;
        self.hideNavBarOnClose  = self.navigationBar.hidden;
    }
    
    //add the loading bar to the view
    if (self.showLoadingBar) {
        self.progressObserver = [self.webView aapl_addObserverForKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew withBlock:^(id obj, NSDictionary *change, id observer) {
            [self setLoadingProgress:[change[NSKeyValueChangeNewKey] floatValue]];
        }];
    }
    
    //create the buttons view and add them to either the navigation bar or toolbar
    self.buttonsContainerView = [self containerViewWithNavigationButtons];
    if (iPad()) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.buttonsContainerView];
    }
    else {
        NSArray *items = @[BLANK_BARBUTTONITEM, [[UIBarButtonItem alloc] initWithCustomView:self.buttonsContainerView], BLANK_BARBUTTONITEM];
        self.toolbarItems = items;
    }
    
    //override the tint color of the buttons, if desired.
    self.buttonsContainerView.tintColor = self.buttonTintColor;
    
    // Create the Done button
    if (self.showDoneButton && self.beingPresentedModally && !self.onTopOfNavigationControllerStack) {
        NSString *title = NSLocalizedStringFromTable(@"Done", @"TOWebViewControllerLocalizable", @"Modal Web View Controller Close");
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonTapped:)];
        if (iPad())
            self.navigationItem.leftBarButtonItem = doneButton;
        else
            self.navigationItem.rightBarButtonItem = doneButton;
    }
    
    //Set the appropriate actions to the buttons
    [self.backButton        addTarget:self action:@selector(backButtonTapped:)          forControlEvents:UIControlEventTouchUpInside];
    [self.forwardButton     addTarget:self action:@selector(forwardButtonTapped:)       forControlEvents:UIControlEventTouchUpInside];
    [self.reloadStopButton  addTarget:self action:@selector(reloadStopButtonTapped:)    forControlEvents:UIControlEventTouchUpInside];
    [self.actionButton      addTarget:self action:@selector(actionButtonTapped:)        forControlEvents:UIControlEventTouchUpInside];
}

-(void)dealloc{
    [self.webView aapl_removeObserver:self.progressObserver];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //see if we need to show the toolbar
    if (self.navigationController) {
        if (iPad() == NO) { //iPhone
            if (self.beingPresentedModally == NO) { //being pushed onto a pre-existing stack, so
                [self.navigationController setToolbarHidden:self.navigationButtonsHidden animated:animated];
                [self.navigationController setNavigationBarHidden:NO animated:animated];
            }
            else { //Being presented modally, so control the
                self.navigationController.toolbarHidden = self.navigationButtonsHidden;
            }
        }
        else {
            [self.navigationController setNavigationBarHidden:NO animated:animated];
            [self.navigationController setToolbarHidden:YES animated:animated];
        }
    }
    
    //start loading the initial page
    if (self.url && self.webView.URL == nil)
    {
        [self.webView loadRequest:self.urlRequest];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.beingPresentedModally == NO) {
        [self.navigationController setToolbarHidden:self.hideToolbarOnClose animated:animated];
        [self.navigationController setNavigationBarHidden:self.hideNavBarOnClose animated:animated];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}


#pragma mark -
#pragma mark State Tracking
- (BOOL)beingPresentedModally
{
    // Check if we have a parent navigation controller, it's being presented modally,
    // and if it is, that we are its root view controller
    if (self.navigationController && self.navigationController.presentingViewController)
        return ([self.navigationController.viewControllers indexOfObject:self] == 0);
    else // Check if we're being presented modally directly
        return ([self presentingViewController] != nil);
    
    return NO;
}

- (BOOL)onTopOfNavigationControllerStack
{
    if (self.navigationController == nil)
        return NO;
    
    if ([self.navigationController.viewControllers count] && [self.navigationController.viewControllers indexOfObject:self] > 0)
        return YES;
    
    return NO;
}

#pragma mark -
#pragma mark Manual Property Accessors
- (void)setUrl:(NSURL *)url
{
    if (self.url == url)
        return;
    
    _url = [self cleanURL:url];
    
    if (self.webView.loading)
        [self.webView stopLoading];
    
    [self.webView loadRequest:self.urlRequest];
}

- (UINavigationBar *)navigationBar
{
    if (self.navigationController)
        return self.navigationController.navigationBar;
    
    return nil;
}

- (UIToolbar *)toolbar
{
    if (iPad())
        return nil;
    
    if (self.navigationController)
        return self.navigationController.toolbar;
    
    return nil;
}

- (void)setNavigationButtonsHidden:(BOOL)navigationButtonsHidden
{
    if (navigationButtonsHidden == _navigationButtonsHidden)
        return;
    
    _navigationButtonsHidden = navigationButtonsHidden;
    
    if (_navigationButtonsHidden == NO)
    {
        [self setUpNavigationButtons];
        UIView *iconsContainerView = [self containerViewWithNavigationButtons];
        if (iPad()) {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:iconsContainerView];
        }
        else {
            NSArray *items = @[BLANK_BARBUTTONITEM, [[UIBarButtonItem alloc] initWithCustomView:iconsContainerView], BLANK_BARBUTTONITEM];
            self.toolbarItems = items;
        }
    }
    else
    {
        if (iPad()) {
            self.navigationItem.rightBarButtonItem  = nil;
        }
        else {
            self.navigationController.toolbarItems = nil;
            self.navigationController.toolbarHidden = YES;
        }
        
        self.backButton = nil;
        self.forwardButton = nil;
        self.reloadIcon = nil;
        self.stopIcon = nil;
        self.reloadStopButton = nil;
        self.actionButton = nil;
    }
}

- (void)setButtonTintColor:(UIColor *)buttonTintColor
{
    if (buttonTintColor == _buttonTintColor)
        return;
    
    _buttonTintColor = buttonTintColor;
    
    self.buttonsContainerView.tintColor = _buttonTintColor;
}

#pragma mark -
#pragma mark WebView Delegate

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    //start tracking the load state
    [self startLoadProgress];
    
    //update the navigation bar buttons
    [self refreshButtonsState];
}

-(void)webView:(nonnull WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    [self handleLoadRequestCompletion];
    [self refreshButtonsState];
    
    //see if we can set the proper page title at this point
    if (self.showPageTitles)
        [self.webView evaluateJavaScript:@"document.title" completionHandler:^(NSString *result, NSError *error) {
            self.title = result;
        }];
    
    if (self.channelConfiguration[@"fontSize"]) {
        NSString *setTextSizeRule = [NSString stringWithFormat:@"document.body.style.fontSize = %@;", self.channelConfiguration[@"fontSize"]];
        [self.webView evaluateJavaScript:setTextSizeRule completionHandler:nil];
    }
}

-(void)webView:(nonnull WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(nonnull NSError *)error{
    [self handleLoadRequestCompletion];
    [self refreshButtonsState];
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
        //if we were loading, hide the load bar for now
    }
    else {
        //In certain cases, if the connection drops out preload or midload,
        //it nullifies webView.request, which causes [webView reload] to stop working.
        //This checks to see if the webView request URL is nullified, and if so, tries to load
        //off our stored self.url property instead
        if (self.webView.URL.absoluteString.length == 0 && self.url)
        {
            [self.webView loadRequest:self.urlRequest];
        }
        else {
            [self.webView reload];
        }
    }
    
    //refresh the buttons
    [self refreshButtonsState];
}

- (void)doneButtonTapped:(id)sender
{
   // [self.presentingViewController dismissViewControllerAnimated:YES completion:self.modalCompletionHandler];
}


#pragma mark -
#pragma mark Action Item Event Handlers
- (void)actionButtonTapped:(id)sender
{
    NSArray *browserActivities = @[[TOActivitySafari new], [TOActivityChrome new]];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[self.url] applicationActivities:browserActivities];
    
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

- (void)handleLoadRequestCompletion
{
    //Query the webview to see what load state JavaScript perceives it at
    [self.webView evaluateJavaScript:@"document.readyState" completionHandler:^(NSString *readyState, NSError *error) {
        
        //interactive means the page has loaded sufficiently to allow user interaction now
        BOOL interactive = [readyState isEqualToString:@"interactive"];
        if (interactive)
        {
            //see if we can set the proper page title yet
            if (self.showPageTitles)
                [self.webView evaluateJavaScript:@"document.title" completionHandler:^(NSString *title, NSError *error) {
                    self.title = title;
                }];
            
            //if we're matching the view BG to the web view, update the background colour now
            if (self.hideWebViewBoundaries)
                [self updateWebViewPageBackgroundColor];
            
            //finally, if the app desires it, disable the ability to tap and hold on links
            if (self.disableContextualPopupMenu) {
                [self.webView evaluateJavaScript:@"document.body.style.webkitTouchCallout='none';" completionHandler:nil];
            }
        }
        
        BOOL isNotRedirect = self.url && [self.url isEqual:self.webView.URL];
        BOOL complete = [readyState isEqualToString:@"complete"];
        if (complete && isNotRedirect)
            [self finishLoadProgress];
        
        _url = self.webView.URL;
    }];

}

- (void)startLoadProgress
{
    if (self.webView.isLoading == NO)
        return;
    
    self.loadingBarView.alpha = 1.0f;
    
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

- (void)finishLoadProgress
{
    //reset the load progress
    [self refreshButtonsState];
    
    //in case it didn't succeed yet, try setting the page title again
    if (self.showPageTitles)
        [self.webView evaluateJavaScript:@"document.title" completionHandler:^(NSString *title, NSError *error) {
            self.title = title;
        }];
    
    if (self.reloadStopButton)
        [self.reloadStopButton setImage:self.reloadIcon forState:UIControlStateNormal];
}

- (void)setLoadingProgress:(CGFloat)loadingProgress
{
    //NSLog(@"%f",loadingProgress);
    //Update the loading bar progress to match 
    if (self.showLoadingBar)
    {
        [self.loadingBarView setProgress:(float)loadingProgress animated:YES];

        if (loadingProgress >= 1.0f - FLT_EPSILON)
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (!self.webView.loading) {
                    [UIView animateWithDuration:0.2f animations:^{
                        self.loadingBarView.alpha = 0.0f;
                    } completion:^(BOOL finished) {
                        if (finished) {
                            self.loadingBarView.progress = 0;
                        }
                    }];
                }
            });
        }
    }
}


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

-(void)updateWebViewPageBackgroundColor {
    //Pull the current background colour from the web view
    [self.webView evaluateJavaScript:@"window.getComputedStyle(document.body,null).getPropertyValue('background-color');" completionHandler:^(NSString *rgbString, NSError *error) {
        
        self.webView.backgroundColor = ^(NSString *rgbString) {
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
        }(rgbString);

    }];
}


@end
