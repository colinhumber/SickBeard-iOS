//
//  AFHTTPRequestOperation+NSURLCredential.m
//  SickBeard
//
//  Created by Colin Humber on 11/9/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AFHTTPRequestOperation+NSURLCredential.h"
#import "NSUserDefaults+SickBeard.h"
#import "SBServer.h"

@implementation AFHTTPRequestOperation (NSURLCredential)

//- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
//	if (challenge.previousFailureCount == 0) {
//		SBServer *server = [NSUserDefaults standardUserDefaults].temporaryServer;
//		if (!server) {
//			server = [NSUserDefaults standardUserDefaults].server;
//		}
//		
//		NSURLCredential *credential = [NSURLCredential credentialWithUser:server.username
//																 password:server.password
//															  persistence:NSURLCredentialPersistenceForSession];
//		
//		[challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
//	}
//	else {
//		[[challenge sender] cancelAuthenticationChallenge:challenge];
//	}
//}

@end
