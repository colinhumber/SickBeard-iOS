//
//  SBCommandBuilder.m
//  SickBeard
//
//  Created by Colin Humber on 8/26/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import "SBCommandBuilder.h"
#import "SBServer.h"
#import "GTMNSDictionary+URLArguments.h"

@implementation SBCommandBuilder

+ (NSString *)URLForCommands:(NSArray *)commands server:(SBServer *)server params:(NSDictionary *)params {
	if (!server) {
		return nil;
	}
	
	NSURL *serverUrl = [NSURL URLWithString:server.serviceEndpointPath];
	if (!serverUrl) {
		return nil;
	}
	
	NSString *commandString = [self commandStringForCommands:commands];
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
	
	serverUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", [serverUrl absoluteString], [params gtm_httpArgumentsString]]];
	
	return [serverUrl absoluteString];
}

+ (NSString*)URLForCommand:(SickBeardCommand)command server:(SBServer*)server params:(NSMutableDictionary*)params {
	NSArray *commandArray = @[@(command)];
	
	return [self URLForCommands:commandArray server:server params:params];
}

+ (NSString *)commandStringForCommands:(NSArray *)commands {
	NSMutableArray *components = [NSMutableArray arrayWithCapacity:commands.count];
	
	for (NSNumber *commandObj in commands) {
		NSInteger commandVal = [commandObj integerValue];
		[components addObject:[self commandStringForCommand:commandVal]];
	}
	
	return [components componentsJoinedByString:@"|"];
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
			
		case SickBeardCommandAddRootDirectory:
			commandString = @"sb.addrootdir";
			break;
			
		case SickBeardCommandDeleteRootDirectory:
			commandString = @"sb.deleterootdir";
			break;
			
		case SickBeardCommandSearchTVDB:
			commandString = @"sb.searchtvdb";
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
						
		case SickBeardCommandShowSetQuality:
			commandString = @"show.setquality";
			break;
			
		case SickBeardCommandShowStatus:
			commandString = @"show.stats";
			break;
			
		case SickBeardCommandShowUpdate:
			commandString = @"show.update";
			break;

		case SickBeardCommandShowGetPoster:
			commandString = @"show.getposter";
			break;
		
		case SickBeardCommandShowGetBanner:
			commandString = @"show.getbanner";
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