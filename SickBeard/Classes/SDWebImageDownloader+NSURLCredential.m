//
//  SDWebImageDownloader+NSURLCredential.m
//  SickBeard
//
//  Created by Colin Humber on 11/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SDWebImageDownloader+NSURLCredential.h"
#import "SBServer.h"
#import "SickbeardAPIClient.h"

@implementation SDWebImageDownloader (NSURLCredential)

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	if (challenge.previousFailureCount == 0) {
		SBServer *server = [SickbeardAPIClient sharedClient].currentServer;
		NSURLCredential *credential = [NSURLCredential credentialWithUser:server.username 
																 password:server.password 
															  persistence:NSURLCredentialPersistenceForSession];
		
		[challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
	}
	else {
		[[challenge sender] cancelAuthenticationChallenge:challenge];
	}
}

@end
