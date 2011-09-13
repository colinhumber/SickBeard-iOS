//
//  MaaSEntity.h
//  MaaSive
//
//  Created by Collin Ruffenach on 8/1/11.
//  Copyright (c) 2011 ELC Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MaaSEntity : NSManagedObject {
@private
	NSMutableDictionary *_relationships;
}
@property (nonatomic, retain) NSDate * updated_at;
@property (nonatomic, retain) NSString * MaaSID;
@property (nonatomic, retain) NSDate * synced_at;
@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSMutableDictionary *relationships;

@end