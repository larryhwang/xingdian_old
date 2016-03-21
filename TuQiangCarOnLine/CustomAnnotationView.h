//
//  CustomAnnotationView.h
//  TuQiangCarOnLine
//
//  Created by 123456 on 15/7/2.
//  Copyright (c) 2015年 thinkrace. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface CustomAnnotationView : MKAnnotationView
@property (nonatomic, copy) NSString *message;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, copy) NSString *carIconStr;
@property (nonatomic, strong) UIImageView *carIcon;
@property (nonatomic, strong) UIImageView *imageView;
@property (strong, nonatomic) UIButton *detailButton;

@property (assign, nonatomic) BOOL showTrackInfo;
@end
