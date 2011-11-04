//
//  SBCommandBuilder.m
//  SickBeard
//
//  Created by Colin Humber on 8/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SBCommandBuilder.h"
#import "SBServer.h"
#import "SBServer+SickBeardAdditions.h"
#import "GTMNSDictionary+URLArguments.h"

@interface SBCommandBuilder ()
+ (NSString*)commandStringForCommand:(SickBeardCommand)command;
@end

@implementation SBCommandBuilder

+ (NSString*)URLForCommand:(SickBeardCommand)command server:(SBServer*)server params:(NSMutableDictionary*)params {
	if (!server) {
		return nil;
	}

	NSURL *serverUrl = [NSURL URLWithString:server.serviceEndpointPath];
	if (!serverUrl) {
		return nil;
	}
	
	NSString *commandString = [self commandStringForCommand:command];
	if (!commandString) {
		return nil;
	}
	
	if (!params) {
		params = [NSMutableDictionary dictionaryWithCapacity:1];
	}
	else {
		params = [params mutableCopy];
	}
	
	[params setValue:commandString forKey:@"cmd"];
	
	serverUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@api/%@/?%@", [serverUrl absoluteString], server.apiKey, [params gtm_httpArgumentsString]]];
	
	NSLog(@"URL created: %@", serverUrl);
	return [serverUrl absoluteString];
}

+ (NSString*)commandStringForCommand:(SickBeardCommand)command {
	NSString *commandString = nil;
	
	switch (command) {
		case SickBeardCommandCheckScheduler:
			commandString = @"sb.checkscheduler";
			break;
			
		case SickBeardCommandGetDefaults:
			commandString = @"sb.getdefaults";
			break;
			
		case SickBeardCommandSetDefaults:
			commandString = @"sb.setdefaults";
			break;
						
		case SickBeardCommandForceSearch:
			commandString = @"sb.forcesearch";
			break;
			
		case SickBeardCommandPauseBacklog:
			commandString = @"sb.pausebacklog";
			break;
			
		case SickBeardCommandPing:
			commandString = @"sb.ping";
			break;
			
		case SickBeardCommandRestart:
			commandString = @"sb.restart";
			break;
						
		case SickBeardCommandShutdown:
			commandString = @"sb.shutdown";
			break;
			
		case SickBeardCommandGetRootDirectories:
			commandString = @"sb.getrootdirs";
			break;
			
		case SickBeardCommandComingEpisodes:
			commandString = @"future";
			break;
			
		case SickBeardCommandEpisode:
			commandString = @"episode";
			break;
			
		case SickBeardCommandEpisodeSearch:
			commandString = @"episode.search";
			break;
			
		case SickBeardCommandEpisodeSetStatus:
			commandString = @"episode.setstatus";
			break;
			
		case SickBeardCommandHistory:
			commandString = @"history";
			break;
			
		case SickBeardCommandHistoryClear:
			commandString = @"history.clear";
			break;
			
		case SickBeardCommandHistoryTrim:
			commandString = @"history.trim";
			break;
			
		case SickBeardCommandViewLogs:
			commandString = @"logs";
			break;
			
		case SickBeardCommandSeasonList:
			commandString = @"show.seasonlist";
			break;
			
		case SickBeardCommandSeasons:
			commandString = @"show.seasons";
			break;
			
		case SickBeardCommandShow:
			commandString = @"show";
			break;
			
		case SickBeardCommandShowAddExisting:
			commandString = @"show.addexisting";
			break;
			
		case SickBeardCommandShowAddNew:
			commandString = @"show.addnew";
			break;
			
		case SickBeardCommandShowCache:
			commandString = @"show.cache";
			break;
			
		case SickBeardCommandShowDelete:
			commandString = @"show.delete";
			break;
			
		case SickBeardCommandShowGetQuality:
			commandString = @"show.getquality";
			break;
			
		case SickBeardCommandShowRefresh:
			commandString = @"show.refresh";
			break;
			
		case SickBeardCommandShowSearchTVDB:
			commandString = @"show.searchtvdb";
			break;
			
		case SickBeardCommandShowSetQuality:
			commandString = @"show.setquality";
			break;
			
		case SickBeardCommandShowStatus:
			commandString = @"show.stats";
			break;
			
		case SickBeardCommandShowUpdate:
			commandString = @"show.update";
			break;
			
		case SickBeardCommandShows:
			commandString = @"shows";
			break;
			
		case SickBeardCommandShowsStats:
			commandString = @"shows.stats";
			break;
			
		default:
			break;
	}
	
	return commandString;
}

@end