//
//  DDIntranetContentViewController.m
//  Duoduo
//
//  Created by 独嘉 on 14-6-25.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDIntranetContentViewController.h"
#import "DDIntranetEntity.h"
@interface DDIntranetContentViewController ()

@end

@implementation DDIntranetContentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        self.progressIndicator = [[NSProgressIndicator alloc] init];
        [self.progressIndicator setStyle:NSProgressIndicatorSpinningStyle];
        [self.progressIndicator setControlSize:NSRegularControlSize];
        [self.progressIndicator.layer setBackgroundColor:[NSColor clearColor].CGColor];
        [self.progressIndicator setHidden:YES];
    }
    return self;
}

- (void)awakeFromNib
{
    [self.webView setCustomUserAgent:@"mogujieIM"];
    [self.progressIndicator setFrame:self.iconImageView.frame];
    [[self.iconImageView superview] addSubview:self.progressIndicator];
    [self.backButton setEnabled:[self.webView canGoBack]];
    [self.forwardButton setEnabled:[self.webView canGoForward]];
}

#pragma mark -
#pragma mark IBACtion
- (IBAction)mainWebView:(id)sender
{
    //主页
    [self.webView setMainFrameURL:self.intranetEntity.itemURL];
}

- (IBAction)refresh:(id)sender
{
    //刷新
    NSString* url = [self.webView mainFrameURL];
    [self.webView setMainFrameURL:url];
}

- (IBAction)forward:(id)sender
{
    //前进
    [self.webView goForward];
}

- (IBAction)back:(id)sender
{
    //后退
    [self.webView goBack];
}

#pragma mark -
#pragma mark WebView UIDelegate

- (void)webView:(WebView *)sender makeFirstResponder:(NSResponder *)responder
{
    [[self.view window] makeFirstResponder:sender];
}

- (WebView *)webView:(WebView *)sender createWebViewWithRequest:(NSURLRequest *)request
{
    [[sender mainFrame] loadRequest:request];
    return sender;
}

- (BOOL)webViewAreToolbarsVisible:(WebView *)sender
{
    return YES;
}

- (void)webView:(WebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame
{
    DDLog(@"%@",message);
}

#pragma mark -
#pragma mark WebView mainFrame Delegate
- (void)webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame
{
    [self.titleLabel setStringValue:title];
}

- (void)webView:(WebView *)sender didReceiveIcon:(NSImage *)image forFrame:(WebFrame *)frame
{
    [self.iconImageView setImage:image];
}

- (void)webView:(WebView *)sender didChangeLocationWithinPageForFrame:(WebFrame *)frame
{
    DDLog(@"ascasdc");
}

- (void)webView:(WebView *)sender didReceiveServerRedirectForProvisionalLoadForFrame:(WebFrame *)frame
{
    DDLog(@"ascasc");
}

- (void)webView:(WebView *)sender didFailLoadWithError:(NSError *)error forFrame:(WebFrame *)frame
{
    DDLog(@"as");
}

- (void)webView:(WebView *)sender didFailProvisionalLoadWithError:(NSError *)error forFrame:(WebFrame *)frame
{
    DDLog(@"ascavc");
}

- (void)webView:(WebView *)sender willPerformClientRedirectToURL:(NSURL *)URL delay:(NSTimeInterval)seconds fireDate:(NSDate *)date forFrame:(WebFrame *)frame
{
    DDLog(@"asdafs");
}

- (void)webView:(WebView *)sender didCancelClientRedirectForFrame:(WebFrame *)frame
{
    DDLog(@"asac");
}

#pragma mark - 
#pragma marj webView DataSource Delegate

- (NSURLRequest *)webView:(WebView *)sender resource:(id)identifier willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse fromDataSource:(WebDataSource *)dataSource;
{
    [self.progressIndicator startAnimation:nil];
    [self.iconImageView setHidden:YES];
    [self.progressIndicator setHidden:NO];
    return request;
}

- (void)webView:(WebView *)sender resource:(id)identifier didFinishLoadingFromDataSource:(WebDataSource *)dataSource
{
    [self.progressIndicator stopAnimation:nil];
    [self.progressIndicator setHidden:YES];
    [self.iconImageView setHidden:NO];
    [self.backButton setEnabled:[self.webView canGoBack]];
    [self.forwardButton setEnabled:[self.webView canGoForward]];
}

@end
