//
//  SBNotificationManager.h
//  SickBeard
//
//  Created by Colin Humber on 2/22/13.
//
//

#import <Foundation/Foundation.h>

@class SBNotification;

typedef NS_ENUM(NSInteger, SBNotificationType) {
	SBNotificationTypeInfo,
	SBNotificationTypeNotice,
	SBNotificationTypeSuccess,
	SBNotificationTypeWarning,
	SBNotificationTypeError
};

@interface SBNotificationManager : NSObject

+ (SBNotificationManager *)sharedManager;
- (void)queueNotificationWithText:(NSString *)text type:(SBNotificationType)type inView:(UIView *)hostView;

- (void)notificationDidHide:(SBNotification *)notification;

@end
