//
//  SBWebViewController.h
//  SickBeard
//
//  Created by Colin Humber on 10/18/13.
//
//

@interface SBWebViewController : UINavigationController

- (id)initWithAddress:(NSString*)urlString;
- (id)initWithURL:(NSURL *)URL;

@end
