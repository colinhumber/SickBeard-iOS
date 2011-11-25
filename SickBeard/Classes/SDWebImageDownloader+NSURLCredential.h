//
//  SDWebImageDownloader+NSURLCredential.h
//  SickBeard
//
//  Created by Colin Humber on 11/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SDWebImageDownloader.h"

@interface SDWebImageDownloader (NSURLCredential)

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;

@end
