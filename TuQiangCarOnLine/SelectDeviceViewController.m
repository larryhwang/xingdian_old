//
//  DeviceViewController.m
//  途强
//
//  Created by TR on 13-9-26.
//  Copyright (c) 2013年 thinkrace. All rights reserved.
//

#import "SelectDeviceViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "TrackingViewController.h"
#import "HistoryPeriodViewController.h"
#import "GeoFenceViewController.h"
#import "AlarmViewController.h"
#import "IssuesViewController.h"
#import "UIImage+Scale.h"

#import "IssuesViewController.h"


@interface SelectDeviceViewController ()

@property (strong, nonatomic) UIButton *rightButton;

@end

@implementation SelectDeviceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = MyLocal(@"实时追踪");
        
        NSString *type = [USER_DEFAULT objectForKey:@"Type"];
        if (!([type isEqualToString:@"TR02"] || [type isEqualToString:@"TR02B"] || [type isEqualToString:@"GT02A"] || [type isEqualToString:@"GT02B"] || [type isEqualToString:@"GT02D"] || [type isEqualToString:@"GT200"])) {
            //导航条的右边添加 下拉列表
            _rightButton = [[UIButton alloc] initWithFrame:CGRectMake(180, 0, 36, 26)];
            [_rightButton setBackgroundImage:[UIImage imageNamed:@"7.png"] forState:UIControlStateNormal];
            //    [_rightButton setBackgroundImage:[UIImage imageNamed:@"7.png"] forState:UIControlStateSelected];
            [_rightButton addTarget:self action:@selector(rightButtonAction) forControlEvents:UIControlEventTouchUpInside];
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_rightButton];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    IOS7;
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    // 返回按钮
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 11, 21)];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"j.png"] forState:UIControlStateNormal];
//    [leftButton setBackgroundImage:[UIImage imageNamed:@"j.png"] forState:UIControlStateHighlighted];
    [leftButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    //[USER_DEFAULT setObject:@"ET100" forKey:@"Type"];
//    NSString *type = [USER_DEFAULT objectForKey:@"Type"];
//    if ([type isEqualToString:@"ET100"] || [type isEqualToString:@"GT600"] || [type isEqualToString:@"GT07"] || [type isEqualToString:@"GT06"] || [type isEqualToString:@"GT06A"] || [type isEqualToString:@"GT06B"] || [type isEqualToString:@"GT06N"] || [type isEqualToString:@"GT06M"] || [type isEqualToString:@"TR06"] || [type isEqualToString:@"TR06B"] || [type isEqualToString:@"GPS007"] || [type isEqualToString:@"GT03D"] || [type isEqualToString:@"GT300"] || [type isEqualToString:@"GT03A"] || [type isEqualToString:@"GT03B"] || [type isEqualToString:@"TR03A"] || [type isEqualToString:@"TR03B"] || [type isEqualToString:@"GT05"] || [type isEqualToString:@"GT200"] || [type isEqualToString:@"GT100"]) {
//        self.rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 47, 36)];
//        [_rightButton setBackgroundImage:[UIImage imageNamed:@"6.png"] forState:UIControlStateNormal];
//        [_rightButton setBackgroundImage:[UIImage imageNamed:@"6-1"] forState:UIControlStateHighlighted];
//        [_rightButton addTarget:self action:@selector(issuesOrders) forControlEvents:UIControlEventTouchUpInside];
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_rightButton];
//    }
    
    [self.tabBar setBackgroundImage:[[UIImage imageNamed:@"b"] scaleToSize:CGSizeMake(320, 49)]];// 设置tabBar背景
    self.tabBar.selectionIndicatorImage = [[UIImage imageNamed:@"7-1.png"] scaleToSize:CGSizeMake(76, 45)];// 设置tabBarItem选中的背景
    
    // 实时追踪
	TrackingViewController *trackingView = [[TrackingViewController alloc] init];
    if (BYT_IOS7) {
        trackingView.tabBarItem = [[UITabBarItem alloc]initWithTitle:MyLocal(@"实时追踪") image:[[UIImage imageNamed:@"r.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"r-1.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ]];
        trackingView.tabBarItem.tag = 0;
    }else {
        trackingView.tabBarItem = [[UITabBarItem alloc] initWithTitle:MyLocal(@"实时追踪") image:[UIImage imageNamed:@"r-1.png"] tag:0];
        [trackingView.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"r-1.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"r.png"]];// 设置tabBarItem选中图片
    }
    // 历史轨迹
    HistoryPeriodViewController *historyView = [[HistoryPeriodViewController alloc] init];
    if (BYT_IOS7) {
        historyView.tabBarItem = [[UITabBarItem alloc]initWithTitle:MyLocal(@"历史轨迹") image:[[UIImage imageNamed:@"o.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"o-1.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ]];
        historyView.tabBarItem.tag = 1;
    }else {
        historyView.tabBarItem = [[UITabBarItem alloc] initWithTitle:MyLocal(@"历史轨迹") image:[UIImage imageNamed:@"o-1.png"] tag:1];
        [historyView.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"o-1.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"o.png"]];// 设置tabBarItem选中图片
    }
    
    
    // 电子围栏
    GeoFenceViewController *geofenceView = [[GeoFenceViewController alloc] init];
    if (BYT_IOS7) {
        geofenceView.tabBarItem = [[UITabBarItem alloc]initWithTitle:MyLocal(@"电子围栏") image:[[UIImage imageNamed:@"q.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"q-1.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ]];
        geofenceView.tabBarItem.tag = 2;
    }else{
        geofenceView.tabBarItem = [[UITabBarItem alloc] initWithTitle:MyLocal(@"电子围栏") image:[UIImage imageNamed:@"q-1.png"] tag:2];
        [geofenceView.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"q-1.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"q.png"]];// 设置tabBarItem选中图片
    }
    
    // 设备报警
    AlarmViewController *alarmView = [[AlarmViewController alloc] init];
    if (BYT_IOS7) {
        alarmView.tabBarItem = [[UITabBarItem alloc]initWithTitle:MyLocal(@"车辆报警") image:[[UIImage imageNamed:@"warn.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"warn_select.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ]];
        alarmView.tabBarItem.tag = 3;
    }else{
        alarmView.tabBarItem = [[UITabBarItem alloc] initWithTitle:MyLocal(@"车辆报警") image:[UIImage imageNamed:@"warn_select.png"] tag:3];
        [alarmView.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"warn_select.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"warn.png"]];// 设置tabBarItem选中图片
    }
    
    self.viewControllers = @[trackingView, historyView, geofenceView, alarmView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Target

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)rightButtonAction{
    
    
    IssuesViewController *issuesVC = [[IssuesViewController alloc]init];
    
    [self.navigationController pushViewController:issuesVC animated:YES];
}

- (void)issuesOrders
{
    IssuesViewController *issuesView = [[IssuesViewController alloc] init];
    [self.navigationController pushViewController:issuesView animated:YES];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    switch (item.tag) {
        case 0:{
            self.title = MyLocal(@"实时追踪");
            
            NSString *type = [USER_DEFAULT objectForKey:@"Type"];
            if ([type isEqualToString:@"GT02A"] || [type isEqualToString:@"GT02B"] || [type isEqualToString:@"GT02D"] || [type isEqualToString:@"TR02"] || [type isEqualToString:@"TR02B"] || [type isEqualToString:@"GT200"]) {
                [self.rightButton setHidden:YES];
                _rightButton.alpha = 0.0;
            } else {
                [self.rightButton setHidden:NO];
                _rightButton.alpha = 1.0;
            }
        }
            break;
        case 1:
            [self.rightButton setHidden:YES];
            self.title = MyLocal(@"历史轨迹");
            _rightButton.alpha = 0.0;
            break;
        case 2:
            self.title = MyLocal(@"电子围栏");
            _rightButton.alpha = 0.0;
            break;
        case 3:
            self.title = MyLocal(@"车辆报警");
            _rightButton.alpha = 0.0;
            break;
        default:
            break;
    }
}
- (UIImage*)createImageWithColor: (UIColor*) color
{
    CGRect rect=CGRectMake(0,0, VIEW_WIDTH , 49);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}
@end
