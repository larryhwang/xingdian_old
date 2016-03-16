//
//  DeviceDetail.m
//  NewGps2012
//
//  Created by TR on 13-3-4.
//  Copyright (c) 2013年 thinkrace. All rights reserved.
//

#import "DeviceDetail.h"

@implementation DeviceDetail

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.deviceName = [aDecoder decodeObjectForKey:@"deviceName"];
        self.deviceIMEI = [aDecoder decodeObjectForKey:@"deviceIMEI"];
        self.deviceValidity = [aDecoder decodeObjectForKey:@"deviceValidity"];
        self.deviceLicencePlate = [aDecoder decodeObjectForKey:@"deviceLicencePlate"];
        self.deviceType = [aDecoder decodeObjectForKey:@"deviceType"];
        self.deviceSim = [aDecoder decodeObjectForKey:@"deviceSim"];
        self.deviceContactPerson = [aDecoder decodeObjectForKey:@"deviceContactPerson"];
        self.deviceContactTelephone = [aDecoder decodeObjectForKey:@"deviceContactTelephone"];
        self.deviceAddress = [aDecoder decodeObjectForKey:@"deviceAddress"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_deviceName forKey:@"deviceName"];
    [aCoder encodeObject:_deviceIMEI forKey:@"deviceIMEI"];
    [aCoder encodeObject:_deviceValidity forKey:@"deviceValidity"];
    [aCoder encodeObject:_deviceLicencePlate forKey:@"deviceLicencePlate"];
    [aCoder encodeObject:_deviceType forKey:@"deviceType"];
    [aCoder encodeObject:_deviceSim forKey:@"deviceSim"];
    [aCoder encodeObject:_deviceContactPerson forKey:@"deviceContactPerson"];
    [aCoder encodeObject:_deviceContactTelephone forKey:@"deviceContactTelephone"];
    [aCoder encodeObject:_deviceAddress forKey:@"deviceAddress"];
}

@end
