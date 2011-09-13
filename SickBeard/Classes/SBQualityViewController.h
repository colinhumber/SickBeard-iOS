//
//  SBQualityViewController.h
//  SickBeard
//
//  Created by Colin Humber on 9/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	QualityTypeInitial,
	QualityTypeArchive
} QualityType;

@protocol SBQualityViewControllerDelegate;

@interface SBQualityViewController : UITableViewController {
	NSArray *qualities;
}

@property (nonatomic, assign) id<SBQualityViewControllerDelegate> delegate;
@property (nonatomic, assign) QualityType qualityType;
@property (nonatomic, retain) NSMutableArray *currentQuality;

@end


@protocol SBQualityViewControllerDelegate <NSObject>

- (void)qualityViewController:(SBQualityViewController*)controller didSelectQualities:(NSArray*)qualities;

@end