//
//  GeoFenceInfoView.h
//  途强汽车在线
//
//  Created by apple on 14-5-22.
//  Copyright (c) 2014年 thinkrace. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GeoFenceInfoView : UIView

@property (strong, nonatomic) UITextField *nameTextField;
@property (copy, nonatomic) NSString *type;
@property (copy, nonatomic) NSString *geotype;
@property (strong, nonatomic) UIButton *leftButton;
@property (strong, nonatomic) UIButton *rightButton;
@property (assign, nonatomic) BOOL isModel;
@end
