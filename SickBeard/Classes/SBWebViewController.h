//
//  SBWebViewController.h
//  SickBeard
//
//  Created by Colin Humber on 10/18/13.
//
//

#import "CRNavigationController.h"

@interface SBWebViewController : CRNavigationController

- (id)initWithAddress:(NSString*)urlString;
- (id)initWithURL:(NSURL *)URL;

@end
