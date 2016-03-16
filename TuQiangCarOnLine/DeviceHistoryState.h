//
//  DeviceHistoryState.h
//  NewGps2012
//
//  Created by TR on 13-3-14.
//  Copyright (c) 2013年 thinkrace. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceHistoryState : NSObject
{
    NSString *date;
    NSString *latitude;
    NSString *longitude;
    NSString *speed;
    NSString *isStop;
    NSString *icon;
}
@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) NSString *latitude;
@property (strong, nonatomic) NSString *longitude;
@property (strong, nonatomic) NSString *speed;
@property (strong, nonatomic) NSString *isStop;
@property (strong, nonatomic) NSString *icon;
@end
