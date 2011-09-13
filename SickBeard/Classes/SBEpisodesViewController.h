//
//  SBEpisodesViewController.h
//  SickBeard
//
//  Created by Colin Humber on 8/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OrderedDictionary;

@interface SBEpisodesViewController : UIViewController {
	OrderedDictionary *comingEpisodes;
}

@property (retain, nonatomic) IBOutlet UITableView *tableView;

@end
