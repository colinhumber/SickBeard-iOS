//
//  SBQualityViewController.h
//  SickBeard
//
//  Created by Colin Humber on 9/8/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
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

@property (nonatomic, unsafe_unretained) id<SBQualityViewControllerDelegate> delegate;
@property (nonatomic, assign) QualityType qualityType;
@property (nonatomic, strong) NSMutableArray *currentQuality;

@end


@protocol SBQualityViewControllerDelegate <NSObject>

- (void)qualityViewController:(SBQualityViewController*)controller didSelectQualities:(NSArray*)qualities;

@end