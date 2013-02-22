//
//  SBNotificationManager.m
//  SickBeard
//
//  Created by Colin Humber on 2/22/13.
//
//

#import "SBNotificationManager.h"
#import "MTInfoPanel.h"

@interface SBNotification : NSObject
@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) SBNotificationType type;
@property (nonatomic, weak) SBNotificationManager *manager;
@property (nonatomic, weak) UIView *hostView;

- (void)show;

@end

@implementation SBNotification

- (id)initWithText:(NSString *)text type:(SBNotificationType)type hostView:(UIView *)hostView {
	self = [super init];
	
	if (self) {
		self.text = text;
		self.type = type;
		self.hostView = hostView;
	}
	
	return self;
}

- (void)show {
	MTInfoPanel *infoPanel = [MTInfoPanel showPanelInView:self.hostView
													 type:(MTInfoPanelType)self.type
													title:self.text
												 subtitle:nil
												hideAfter:2.0f];
	
	if (_manager) {
		infoPanel.delegate = self;
		infoPanel.onFinished = @selector(notificationDidHide);
	}
}

- (void)notificationDidHide {
	[self.manager notificationDidHide:self];
}

@end

@interface SBNotificationManager ()
@property (nonatomic, strong) NSMutableArray *queue;
@end

@implementation SBNotificationManager

+ (SBNotificationManager *)sharedManager {
	static SBNotificationManager *_sharedManager = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_sharedManager = [[self alloc] init];
	});
	
	return _sharedManager;
}

- (id)init {
	self = [super init];
	
	if (self) {
		_queue = [[NSMutableArray alloc] initWithCapacity:4];
	}
	
	return self;
}

- (void)queueNotificationWithText:(NSString *)text type:(SBNotificationType)type inView:(UIView *)hostView {
	if (!text || text.length == 0) {
		return;
	}
	
	SBNotification *notification = [[SBNotification alloc] initWithText:text type:type hostView:hostView];
	notification.manager = self;
	
	[_queue addObject:notification];
	
	if (_queue.count == 1) {
		[notification show];
	}
}

- (void)notificationDidHide:(SBNotification *)notification {
	[_queue removeObject:notification];
	
	if (_queue.count > 0) {
		SBNotification *notification = _queue[0];
		[notification show];
	}
}

@end
