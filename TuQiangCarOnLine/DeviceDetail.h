//
//  DeviceDetail.h
//  NewGps2012
//
//  Created by TR on 13-3-4.
//  Copyright (c) 2013年 thinkrace. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceDetail : NSObject <NSCoding>

@property (strong, nonatomic) NSString *deviceName;
@property (strong, nonatomic) NSString *deviceIMEI;
@property (strong, nonatomic) NSString *deviceValidity;
@property (strong, nonatomic) NSString *deviceLicencePlate;
@property (strong, nonatomic) NSString *deviceType;
@property (strong, nonatomic) NSString *deviceSim;
@property (strong, nonatomic) NSString *deviceContactPerson;
@property (strong, nonatomic) NSString *deviceContactTelephone;
@property (strong, nonatomic) NSString *deviceAddress;

@end
