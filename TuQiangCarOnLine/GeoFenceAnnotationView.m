//
//  GeoFenceAnnotationView.m
//  途强汽车在线
//
//  Created by apple on 14-5-13.
//  Copyright (c) 2014年 thinkrace. All rights reserved.
//

#import "GeoFenceAnnotationView.h"

@interface GeoFenceAnnotationView ()

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *typeLabel;
@property (strong, nonatomic) UILabel *radiusLabel;
@property (strong, nonatomic) UILabel *numberLabel;

@end

@implementation GeoFenceAnnotationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.frame = CGRectMake(0.0f, 0.0f, 160.0f, 210.0f);
        
        self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_popup_2"]];
        _imageView.userInteractionEnabled = YES;
        _imageView.frame = CGRectMake(0, 0, 160, 80);
        _imageView.hidden = YES;
        [self addSubview:_imageView];
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 5, 100, 20)];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textColor = [UIColor blueColor];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.font = [UIFont systemFontOfSize:14.0f];
        [_imageView addSubview:_nameLabel];
        
        self.typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 25, 150, 20)];
        _typeLabel.backgroundColor = [UIColor clearColor];
        _typeLabel.textColor = [UIColor blueColor];
        _typeLabel.font = [UIFont systemFontOfSize:14.0f];
        [_imageView addSubview:_typeLabel];
        
        self.radiusLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 45, 150, 20)];
        _radiusLabel.backgroundColor = [UIColor clearColor];
        _radiusLabel.textColor = [UIColor blueColor];
        _radiusLabel.font = [UIFont systemFontOfSize:13.0f];
        [_imageView addSubview:_radiusLabel];
        
        self.numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 20, 20)];
        _numberLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"circle"]];
        _numberLabel.textAlignment = NSTextAlignmentCenter;
        _numberLabel.font = [UIFont boldSystemFontOfSize:13.0];
        _numberLabel.textColor = [UIColor blueColor];
        [_imageView addSubview:_numberLabel];
        
        UIImageView *poiView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 53)];
        poiView.image = [UIImage imageNamed:@"POI"];
        poiView.center = self.center;
        [self addSubview:poiView];
    }
    return self;
}

- (void)setName:(NSString *)name
{
    _name = name;
    _nameLabel.text = name;
}

- (void)setType:(NSString *)type
{
    _type = type;
    if ([type isEqualToString:@"All"]) {
        _typeLabel.text = [NSString stringWithFormat:@"%@:%@", MyLocal(@"围栏类型"), MyLocal(@"进出围栏报警")];
    } else if ([type isEqualToString:@"OUT"]) {
        _typeLabel.text = [NSString stringWithFormat:@"%@:%@", MyLocal(@"围栏类型"), MyLocal(@"出围栏报警")];
    } else if ([type isEqualToString:@"IN"]) {
        _typeLabel.text = [NSString stringWithFormat:@"%@:%@", MyLocal(@"围栏类型"), MyLocal(@"进围栏报警")];
    }
}

- (void)setNumber:(NSInteger)number
{
    _number = number;
    _numberLabel.text = [NSString stringWithFormat:@"%ld", (long)number];
}

- (void)setRadius:(NSInteger)radius
{
    _radius = radius;
    _radiusLabel.text = [NSString stringWithFormat:@"%@:%ld%@", MyLocal(@"半径"), (long)radius, MyLocal(@"米")];
}

- (void)setShowCallout:(BOOL)showCallout
{
    _showCallout = showCallout;
    _imageView.hidden = !showCallout;
}

@end
