//
//  SickbeardAPIClient.m
//  SickBeard
//
//  Created by Colin Humber on 8/29/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import "SickbeardAPIClient.h"
#import "SBCommandBuilder.h"
#import "SBServer.h"
#import "AFJSONRequestOperation.h"
#import "NSUserDefaults+SickBeard.h"
#import "SBRootDirectory.h"

NSString *const RESULT_SUCCESS = @"success";
NSString *const RESULT_FAILURE = @"failure";
NSString *const RESULT_TIMEOUT = @"timeout";
NSString *const RESULT_ERROR = @"error";
NSString *const RESULT_FATAL = @"fatal";
NSString *const RESULT_DENIED = @"denied";

@implementation SickbeardAPIClient

- (id)initWithBaseURL:(NSURL *)url {
	self = [super initWithBaseURL:url];
	
	if (self) {
		[self registerHTTPOperationClass:[AFJSONRequestOperation class]];		
		[self setDefaultHeader:@"Accept" value:@"application/json"];
	}
	
	return self;
}

- (NSURL*)posterURLForTVDBID:(NSString*)tvdbID {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	SBServer *currentServer = defaults.server;
	
	NSDictionary *parameters = [NSDictionary dictionaryWithObject:tvdbID forKey:@"tvdbid"];
	NSString *url = [SBCommandBuilder URLForCommand:SickBeardCommandShowGetPoster server:currentServer params:parameters];
	return [NSURL URLWithString:url];
}

- (NSURL*)bannerURLForTVDBID:(NSString*)tvdbID {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	SBServer *currentServer = defaults.server;

	NSDictionary *parameters = [NSDictionary dictionaryWithObject:tvdbID forKey:@"tvdbid"];
	NSString *url = [SBCommandBuilder URLForCommand:SickBeardCommandShowGetBanner server:currentServer params:parameters];
	return [NSURL URLWithString:url];
}

- (void)loadDefaults {
	NSArray *commands = [NSArray arrayWithObjects:
						 [NSNumber numberWithInteger:SickBeardCommandGetDefaults],
						 [NSNumber numberWithInteger:SickBeardCommandGetRootDirectories], 
						 nil];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	SBServer *currentServer = defaults.server;
	
	if (currentServer.proxyUsername.length > 0 && currentServer.proxyPassword.length > 0) {
		[self setAuthorizationHeaderWithUsername:currentServer.proxyUsername password:currentServer.proxyPassword];
	}
	
	[self getPath:nil
	   parameters:@{ @"cmd" : [SBCommandBuilder commandStringForCommands:commands] }
		  success:^(AFHTTPRequestOperation *operation, id JSON) {
			  NSString *result = [JSON objectForKey:@"result"];
			  
			  if ([result isEqualToString:RESULT_SUCCESS]) {
				  NSDictionary *data = [JSON objectForKey:@"data"];
				  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
				  
				  // DEFAULTS
				  NSDictionary *defaultsDict = [data objectForKey:@"sb.getdefaults"];
				  NSDictionary *defaultsData = [defaultsDict objectForKey:@"data"];
				  NSArray *archives = [SBGlobal qualitiesFromCodes:[defaultsData objectForKey:@"archive"]];
				  NSArray *initial = [SBGlobal qualitiesFromCodes:[defaultsData objectForKey:@"initial"] ];
				  BOOL useSeasonFolders = [[defaultsData objectForKey:@"season_folders"] boolValue];
				  NSString *status = [defaultsData objectForKey:@"status"];
				  
				  defaults.archiveQualities = [NSMutableArray arrayWithArray:archives];
				  defaults.initialQualities = [NSMutableArray arrayWithArray:initial];
				  defaults.useSeasonFolders = useSeasonFolders;
				  defaults.status = status;
				  
				  // ROOT DIRECTORIES
				  NSDictionary *dirsDict = [data objectForKey:@"sb.getrootdirs"];
				  NSArray *dirsData = [dirsDict objectForKey:@"data"];
				  
				  NSMutableArray *directories = [NSMutableArray arrayWithCapacity:dirsData.count];
				  for (NSDictionary *dir in dirsData) {
					  SBRootDirectory *directory = [SBRootDirectory itemWithDictionary:dir];
					  if (directory.isValid) {
						  [directories addObject:directory];
					  }
				  }
				  
				  defaults.defaultDirectories = directories;
				  
				  [defaults synchronize];
			  }
		  }
		  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			  NSLog(@"Error getting defaults: %@", error);
		  }];
}

- (void)runCommand:(SickBeardCommand)command parameters:(NSDictionary*)parameters success:(APISuccessBlock)success failure:(APIErrorBlock)failure {
	NSMutableDictionary *parametersCopy;
	
	if (!parameters) {
		parametersCopy = [[NSMutableDictionary alloc] init];
	}
	else {
		parametersCopy = [parameters mutableCopy];
	}
	
	parametersCopy[@"cmd"] = [SBCommandBuilder commandStringForCommand:command];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	SBServer *currentServer = defaults.server;
	
	if (currentServer.proxyUsername.length > 0 && currentServer.proxyPassword.length > 0) {
		[self setAuthorizationHeaderWithUsername:currentServer.proxyUsername password:currentServer.proxyPassword];
	}
	
	[self getPath:nil
	   parameters:parametersCopy
		  success:success
		  failure:failure];
}

@end
