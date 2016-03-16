//
//  CustomAnnotitionView.h
//  NewGps2012
//
//  Created by TR on 13-2-21.
//  Copyright (c) 2013年 thinkrace. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface CustomAnnotitionView : MKAnnotationView

@property (nonatomic, copy) NSString *message;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, copy) NSString *carIconStr;
@property (nonatomic, strong) UIImageView *carIcon;
@property (nonatomic, strong) UIImageView *imageView;
@property (strong, nonatomic) UIButton *detailButton;

@property (assign, nonatomic) BOOL showTrackInfo;

@end
