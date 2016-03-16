//
//  DeviceInfoCell.h
//  NewGps2012
//
//  Created by TR on 13-2-4.
//  Copyright (c) 2013年 thinkrace. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceInfoCell : UITableViewCell
{
    NSString *imageName;
    UIImageView *deviceImage;
    UILabel *statusLabel;
    UILabel *deviceNameLabel;
    UILabel *licencePlateLabel;
}
@property (strong , nonatomic) NSString *imageName;
@property (strong , nonatomic) UIImageView *deviceImage;
@property (strong , nonatomic) UILabel *statusLabel;
@property (strong , nonatomic) UILabel *deviceNameLabel;
@property (strong , nonatomic) UILabel *licencePlateLabel;

@end
