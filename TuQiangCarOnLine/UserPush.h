//
//  UserPush.h
//  贝贝安
//
//  Created by MapleStory on 14/12/23.
//  Copyright (c) 2014年 thinkrace. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserPush : NSObject
@property (copy, nonatomic) NSString *acc;
@property (copy, nonatomic) NSString *isPush;
@property (copy, nonatomic) NSString *sound;
@property (copy, nonatomic) NSString *shock;
@property (copy, nonatomic) NSString *allDayPush;
@property (copy, nonatomic) NSString *startTime;
@property (copy, nonatomic) NSString *endTime;

-(instancetype)initWithUserPush:(NSDictionary *)userPush;
@end
