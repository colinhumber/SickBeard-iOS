//
//  SBWebViewController.m
//  SickBeard
//
//  Created by Colin Humber on 10/18/13.
//
//

#import "SBWebViewController.h"
#import <SAMWebView/SAMWebViewController.h>

@interface SAMWebViewController ()
- (void)close:(id)sender;	// suppress compiler warning for missing selector
@end


@interface SBWebViewController ()
@property (nonatomic, strong) SAMWebViewController *webViewController;
@end

@implementation SBWebViewController

- (id)initWithAddress:(NSString*)urlString {
    return [self initWithURL:[NSURL URLWithString:urlString]];
}

- (id)initWithURL:(NSURL *)URL {
    self.webViewController = [[SAMWebViewController alloc] init];
	[self.webViewController.webView loadURL:URL];
	
    if (self = [super initWithRootViewController:self.webViewController]) {
        self.webViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarStyleDefault target:self.webViewController action:@selector(close:)];
	}
	
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:NO];
    
    self.webViewController.title = self.title;
}

@end
