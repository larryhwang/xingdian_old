//
//  DeviceInfoCell.m
//  NewGps2012
//
//  Created by TR on 13-2-4.
//  Copyright (c) 2013年 thinkrace. All rights reserved.
//

#import "DeviceInfoCell.h"

@implementation DeviceInfoCell
@synthesize imageName;
@synthesize deviceImage;
@synthesize statusLabel;
@synthesize deviceNameLabel;
@synthesize licencePlateLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.deviceImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png", imageName]]];
        deviceImage.frame = CGRectMake(15, 8, 39, 22);
        deviceImage.backgroundColor = [UIColor clearColor];
        [self addSubview:deviceImage];
        
        self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 30, 43, 20)];
        statusLabel.backgroundColor = [UIColor clearColor];
        statusLabel.font = [UIFont systemFontOfSize:14.0];
        [self addSubview:statusLabel];
        
        self.deviceNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 0, 276, 28)];
        deviceNameLabel.backgroundColor = [UIColor clearColor];
        deviceNameLabel.font = [UIFont systemFontOfSize:17.0];
        [self addSubview:deviceNameLabel];
        
        self.licencePlateLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 30, 276, 20)];
        licencePlateLabel.backgroundColor = [UIColor clearColor];
        licencePlateLabel.font = [UIFont systemFontOfSize:14.0];
        licencePlateLabel.textColor = [UIColor colorWithRed:185/255.0 green:132/255.0 blue:88/255.0 alpha:1.0];
        [self addSubview:licencePlateLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
