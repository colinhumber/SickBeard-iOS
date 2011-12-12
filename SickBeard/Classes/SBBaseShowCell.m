//
//  SBBaseShowCell.m
//  SickBeard
//
//  Created by Colin Humber on 12/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SBBaseShowCell.h"
#import "JSONKit.h"
#import "SBITunesUrlCache.h"
#import "GTMNSString+URLArguments.h"
#import "SBGradientView.h"

@implementation SBBaseShowCell

@synthesize showImageView;
@synthesize containerView;

- (void)commonInit {
	// Initialization code
//	SBGradientView *gradientView = [[SBGradientView alloc] init];
//	gradientView.colors = [NSArray arrayWithObjects:
//						   (id)RGBCOLOR(245, 241, 226).CGColor, 
//						   (id)RGBCOLOR(223, 218, 206).CGColor, 
//						   nil];
//	self.backgroundView = gradientView;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		[self commonInit];		
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	
	if (self) {
		[self commonInit];
	}
	
	return self;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
	[super setHighlighted:highlighted animated:animated];
	
	if (highlighted) {
		self.containerView.image = [UIImage imageNamed:@"list-item-background-selected"];
	}
	else {
		self.containerView.image = [UIImage imageNamed:@"list-item-background"];		
	}
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)prepareForReuse {
	self.showImageView.image = nil;
	[super prepareForReuse];
}

#pragma mark - iTunes
- (void)findMatch:(NSArray*)results showName:(NSString*)showName {
	BOOL matchFound = NO;
	
	for (NSDictionary *result in results) {
		if ([[[result objectForKey:@"artistName"] lowercaseString] isEqualToString:[showName lowercaseString]] ||
			[[[result objectForKey:@"collectionName"] lowercaseString] isEqualToString:[showName lowercaseString]]) {
			NSString *imageUrl = [result objectForKey:@"artworkUrl100"];
			
			//NSLog(@"Show name: %@\nImage URL: %@", showName, imageUrl);
			[[SBITunesUrlCache sharedCache] setImageUrlPath:imageUrl forKey:showName];
			
			dispatch_async(dispatch_get_main_queue(), ^{
				[self.showImageView setImageWithURL:[NSURL URLWithString:imageUrl] 
									 placeholderImage:nil];	
			});
	
			matchFound = YES;
			break;
		}
	}
	
	if (!matchFound) {
		dispatch_async(dispatch_get_main_queue(), ^{
			self.showImageView.image = [UIImage imageNamed:@"Icon"];
		});
	}
}

- (void)findiTunesArtworkForShow:(NSString*)showName {
	NSString *sanitizedShowName = showName;
	
	// sanitize showname first 
	if ([showName rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"()"]].location != NSNotFound) {
		NSString *foundData = @"";
		int left, right;
		
		NSScanner *scanner = [NSScanner scannerWithString:showName];
		[scanner scanUpToString:@"(" intoString:nil];
		left = [scanner scanLocation];
		
		[scanner scanUpToString:@")" intoString:nil];
		right = [scanner scanLocation] + 1;
		
		foundData = [showName substringWithRange:NSMakeRange(left, (right - left))];
		
		sanitizedShowName = [[showName stringByReplacingOccurrencesOfString:foundData withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	}
	
	NSString *urlPath = [NSString stringWithFormat:@"http://itunes.apple.com/search?media=tvShow&term=%@", [sanitizedShowName gtm_stringByEscapingForURLArgument]];
	//NSString *urlPath = [NSString stringWithFormat:@"http://itunes.apple.com/search?term=%@", [showName gtm_stringByEscapingForURLArgument]];
	NSString *iTunesLink = [[SBITunesUrlCache sharedCache] imageUrlPathForKey:showName];
	
	if (iTunesLink) {
		[self.showImageView setImageWithURL:[NSURL URLWithString:iTunesLink] 
							 placeholderImage:nil];
	}
	else {
		[NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlPath]] 
								 completionBlock:^(NSData *data, NSURLResponse *response, NSError *error) {
									 NSDictionary *dict = [data objectFromJSONData];
									 NSArray *results = [dict objectForKey:@"results"];
									 
									 if (results.count > 0) {
										 [self findMatch:results showName:sanitizedShowName];
									 }
									 else {
										 // search podcasts
										 NSString *urlPath = [NSString stringWithFormat:@"http://itunes.apple.com/search?media=podcast&term=%@", [sanitizedShowName gtm_stringByEscapingForURLArgument]];
										 
										 [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlPath]] 
																  completionBlock:^(NSData *data, NSURLResponse *response, NSError *error) {
																	  NSDictionary *dict = [data objectFromJSONData];
																	  NSArray *results = [dict objectForKey:@"results"];
																	  
																	  if (results.count > 0) {
																		  [self findMatch:results showName:sanitizedShowName];
																	  }
																	  else {
																		  // load empty
																		  dispatch_async(dispatch_get_main_queue(), ^{
																			  self.showImageView.image = [UIImage imageNamed:@"Icon"];
																		  });
																	  }
																  }];
										 
									 }
									 
								 }];
	}
}

@end
