//
//  SBNotificationManager.h
//  SickBeard
//
//  Created by Colin Humber on 2/22/13.
//
//

#import <Foundation/Foundation.h>

@class SBNotification;

typedef enum {
	SBNotificationTypeInfo,
	SBNotificationTypeNotice,
	SBNotificationTypeSuccess,
	SBNotificationTypeWarning,
	SBNotificationTypeError
} SBNotificationType;

@interface SBNotificationManager : NSObject

+ (SBNotificationManager *)sharedManager;
- (void)queueNotificationWithText:(NSString *)text type:(SBNotificationType)type;

- (void)notificationDidHide:(SBNotification *)notification;

@end
