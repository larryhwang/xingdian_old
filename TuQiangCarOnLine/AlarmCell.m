//
//  DeviceListViewController.m
//  永志高
//
//  Created by apple on 13-12-17.
//  Copyright (c) 2013年 thinkrace. All rights reserved.
//

#import "AlarmCell.h"

@interface AlarmCell ()

@property (strong, nonatomic) UILabel *nameLabel;
//@property (strong, nonatomic) UILabel *modelLabel;
@property (strong, nonatomic) UILabel *alarmTypeLabel;
@property (strong, nonatomic) UILabel *geofenceNameLabel;
@property (strong, nonatomic) UILabel *deviceDateLabel;
@property (strong, nonatomic) UILabel *createDateLabel;

@end

@implementation AlarmCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, CGRectGetWidth(self.frame), 20)];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.font = [UIFont boldSystemFontOfSize:14.0];
        _nameLabel.textColor = [UIColor blackColor];
        [self addSubview:_nameLabel];
        
//        self.modelLabel = [[UILabel alloc] initWithFrame:CGRectMake(180, 0, 135, 20)];
//        _modelLabel.backgroundColor = [UIColor clearColor];
//        _modelLabel.font = [UIFont fontWithName:@"ArialMT" size:14.0];
//        _modelLabel.textColor = [UIColor blackColor];
//        _modelLabel.textAlignment = NSTextAlignmentRight;
//        [self addSubview:_modelLabel];
        
        self.alarmTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 20, 290, 20)];
        _alarmTypeLabel.backgroundColor = [UIColor clearColor];
        _alarmTypeLabel.font = [UIFont fontWithName:@"ArialMT" size:14.0];
        _alarmTypeLabel.textColor = [UIColor redColor];
        [self addSubview:_alarmTypeLabel];
        
        self.geofenceNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 40, 290, 20)];
        _geofenceNameLabel.backgroundColor = [UIColor clearColor];
        _geofenceNameLabel.font = [UIFont fontWithName:@"ArialMT" size:14.0];
        _geofenceNameLabel.textColor = [UIColor blackColor];
        [self addSubview:_geofenceNameLabel];
        
        self.deviceDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 60, 290, 20)];
        _deviceDateLabel.backgroundColor = [UIColor clearColor];
        _deviceDateLabel.font = [UIFont fontWithName:@"ArialMT" size:14.0];
        _deviceDateLabel.textColor = [UIColor blackColor];
        [self addSubview:_deviceDateLabel];
        
        self.createDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 80, 290, 20)];
        _createDateLabel.backgroundColor = [UIColor clearColor];
        _createDateLabel.font = [UIFont fontWithName:@"ArialMT" size:14.0];
        _createDateLabel.textColor = [UIColor blackColor];
        [self addSubview:_createDateLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setName:(NSString *)name
{
    _nameLabel.text = [NSString stringWithFormat:@"%@: %@", MyLocal(@"设备名称"), name];
}

//- (void)setModel:(NSString *)model
//{
//    _modelLabel.text = [NSString stringWithFormat:@"%@: %@", MyLocal(@"设备型号"), model];
//}

- (void)setAlarmType:(NSString *)alarmType
{
    _alarmTypeLabel.text = [NSString stringWithFormat:@"%@: %@", MyLocal(@"报警类型"), alarmType];
}

- (void)setGeofenceName:(NSString *)geofenceName
{
    if (geofenceName.length == 0) {
        _geofenceNameLabel.text = geofenceName;
        [_geofenceNameLabel removeFromSuperview];
    } else {
        [self addSubview:_geofenceNameLabel];
        _geofenceNameLabel.text = [NSString stringWithFormat:@"%@: %@", MyLocal(@"电子栅栏名"), geofenceName];
    }
}

- (void)setDeviceDate:(NSString *)deviceDate
{
    _deviceDateLabel.text = [NSString stringWithFormat:@"%@: %@", MyLocal(@"定位时间"), deviceDate];
    if (_geofenceNameLabel.text.length == 0) {
        _deviceDateLabel.frame = CGRectMake(15, 40, 290, 20);
    } else {
        _deviceDateLabel.frame = CGRectMake(15, 60, 290, 20);
    }
}

- (void)setCreateDate:(NSString *)createDate
{
    _createDateLabel.text = [NSString stringWithFormat:@"%@: %@", MyLocal(@"报警时间"), createDate];
    if (_geofenceNameLabel.text.length == 0) {
        _createDateLabel.frame = CGRectMake(15, 60, 290, 20);
    } else {
        _createDateLabel.frame = CGRectMake(15, 80, 290, 20);
    }
}

@end
