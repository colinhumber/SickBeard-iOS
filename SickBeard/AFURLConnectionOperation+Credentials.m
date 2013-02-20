//
//  AFURLConnectionOperation+Credentials.m
//  SickBeard
//
//  Created by Colin Humber on 2/20/13.
//
//

#import "AFURLConnectionOperation+Credentials.h"
#import "AFURLConnectionOperation.h"

@implementation AFURLConnectionOperation (Credentials)

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
	return YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
		[challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
		return;
	}
}

@end
