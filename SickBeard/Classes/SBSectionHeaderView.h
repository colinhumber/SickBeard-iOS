//
//  SBSectionHeaderView.h
//  SickBeard
//
//  Created by Colin Humber on 12/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SBSectionHeaderView : UIView {
	CGRect _coloredBoxRect;
	CGRect _paperRect;
}

@property (nonatomic, strong) UILabel *sectionLabel;
@property (nonatomic, strong) UIColor *lightColor;
@property (nonatomic, strong) UIColor *darkColor;

@end
