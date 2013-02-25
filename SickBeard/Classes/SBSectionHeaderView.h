//
//  SBSectionHeaderView.h
//  SickBeard
//
//  Created by Colin Humber on 12/13/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	SBSectionHeaderStateOpen,
	SBSectionHeaderStateClosed
} SBSectionHeaderState;

@protocol SBSectionHeaderViewDelegate;

@interface SBSectionHeaderView : UIView

@property (nonatomic) SBSectionHeaderState state;
@property (nonatomic) NSUInteger section;
@property (nonatomic, strong) UILabel *sectionLabel;
@property (nonatomic, strong) UIColor *lightColor;
@property (nonatomic, strong) UIColor *darkColor;
@property (nonatomic, weak) id<SBSectionHeaderViewDelegate> delegate;

@end


@protocol SBSectionHeaderViewDelegate <NSObject>

@optional
-(void)sectionHeaderView:(SBSectionHeaderView*)sectionHeaderView sectionOpened:(NSInteger)section;
-(void)sectionHeaderView:(SBSectionHeaderView*)sectionHeaderView sectionClosed:(NSInteger)section;

@end
