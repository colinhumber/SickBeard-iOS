//
//  SBFaq.h
//  SickBeard
//
//  Created by Colin Humber on 12/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SBFaq : NSObject {
	NSString *_question;
	NSString *_answer;
	BOOL _published;
}

@property (nonatomic, strong) NSString *question;
@property (nonatomic, strong) NSString *answer;
@property (nonatomic) BOOL published;

@end
