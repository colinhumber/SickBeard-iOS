//
//  ShowCell.m
//  SickBeard
//
//  Created by Colin Humber on 9/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ShowCell.h"
#import "JSONKit.h"
#import "SBITunesUrlCache.h"
#import "GTMNSString+URLArguments.h"


@implementation ShowCell

@synthesize posterImageView;
@synthesize showNameLabel;
@synthesize networkLabel;
@synthesize statusLabel;
@synthesize nextEpisodeAirdateLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)prepareForReuse {
	self.posterImageView.image = nil;
	[super prepareForReuse];
}

- (void)findiTunesArtworkForShow:(NSString*)showName {
	NSString *urlPath = [NSString stringWithFormat:@"http://itunes.apple.com/search?entity=tvSeason&media=tvShow&attribute=showTerm&term=%@", [showName gtm_stringByEscapingForURLArgument]];
	NSString *iTunesLink = [[SBITunesUrlCache sharedCache] imageUrlPathForKey:urlPath];
	
	if (iTunesLink) {
		[self.posterImageView setImageWithURL:[NSURL URLWithString:iTunesLink] 
							 placeholderImage:nil];
	}
	else {
		[NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlPath]] 
								 completionBlock:^(NSData *data, NSURLResponse *response, NSError *error) {
									 NSDictionary *dict = [data objectFromJSONData];
									 NSArray *results = [dict objectForKey:@"results"];
									 
									 if (results.count > 0) {
										 for (NSDictionary *result in results) {
											 if ([[[result objectForKey:@"artistName"] lowercaseString] isEqualToString:[showName lowercaseString]]) {
												 NSString *imageUrl = [[results objectAtIndex:0] objectForKey:@"artworkUrl100"];
												 
												 [[SBITunesUrlCache sharedCache] setImageUrlPath:imageUrl forKey:urlPath];
												 
												 dispatch_async(dispatch_get_main_queue(), ^{
													 [self.posterImageView setImageWithURL:[NSURL URLWithString:imageUrl] 
																		  placeholderImage:nil];
												 });
												 
												 break;
											 }
										 }
									 }
									 else {
										 // load placeholder
									 }
//									 if (results.count > 0) {
//										 
//										 NSString *imageUrl = [[results objectAtIndex:0] objectForKey:@"artworkUrl100"];
//										 
//										 [[SBITunesUrlCache sharedCache] setImageUrlPath:imageUrl forKey:urlPath];
//										 
//										 dispatch_async(dispatch_get_main_queue(), ^{
//											 [self.posterImageView setImageWithURL:[NSURL URLWithString:imageUrl] 
//																  placeholderImage:nil];
//										 });
//									 }								 
								 }];
	}
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
