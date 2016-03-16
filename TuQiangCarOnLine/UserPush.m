//
//  UserPush.m
//  贝贝安
//
//  Created by MapleStory on 14/12/23.
//  Copyright (c) 2014年 thinkrace. All rights reserved.
//

#import "UserPush.h"

@implementation UserPush
-(instancetype)initWithUserPush:(NSDictionary *)userPush
{
    self = [super init];
    if (self) {
        _acc = userPush[@"acc"];
        _isPush = userPush[@"IsPush"];
        _sound = userPush[@"Sound"];
        _shock = userPush[@"Shock"];
        _allDayPush = userPush[@"AllDayPush"];
        _startTime = userPush[@"StartTime"];
        _endTime = userPush[@"EndTime"];
    }
    return self;
}
@end
