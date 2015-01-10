//
//  HelpViewController.m
//  TicTacToe
//
//  Created by Diego Cichello on 1/8/15.
//  Copyright (c) 2015 Mobile Makers. All rights reserved.
//

#import "HelpViewController.h"

@interface HelpViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end

@implementation HelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView.delegate = self;
    [self goToURLWithString:@"http://en.wikipedia.org/wiki/Tic-tac-toe"];

}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    self.spinner.hidden = NO;
    [self.spinner startAnimating];

}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.spinner stopAnimating];
    self.spinner.hidden = YES;
}

//Helper method: Loads page using URL string
- (void) goToURLWithString:(NSString *)string
{
    if (![string hasPrefix:@"http://"])
    {
        string = [NSString stringWithFormat:@"http://%@", string];
    }

    NSURL *addressUrl = [NSURL URLWithString:string];
    NSURLRequest *addressRequest = [NSURLRequest requestWithURL:addressUrl];
    [self.webView loadRequest:addressRequest];
    
}



@end
