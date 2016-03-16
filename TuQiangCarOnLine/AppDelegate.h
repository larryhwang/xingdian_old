//
//  AppDelegate.h
//  NewGps2012
//
//  Created by TR on 13-1-28.
//  Copyright (c) 2013年 thinkrace. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    UILabel *_infoLabel;
    UILabel *_udidLabel;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIAlertView *alertView1;
@property (strong, nonatomic) UIAlertView *alertView2;
@property (strong, nonatomic) NSString *ID;
@end
