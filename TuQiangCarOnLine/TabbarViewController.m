//
//  TabbarViewController.m
//  NewGps2012
//
//  Created by TR on 13-2-21.
//  Copyright (c) 2013年 thinkrace. All rights reserved.
//

#import "TabbarViewController.h"
#import "HomeViewController.h"
#import "MapViewController.h"
#import "AllAlarmsViewController.h"
#import "MoreViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Scale.h"
#import "UINavigationBar+CustomImage.h"
#import "ListenViewController.h"
#import "AlarmViewController.h"


@interface TabbarViewController ()

@end

@implementation TabbarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tabbarController = [[UITabBarController alloc] init];
    self.tabbarController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [[UITabBarItem appearance] setTitleTextAttributes:@{UITextAttributeTextColor:[UIColor whiteColor]} forState:UIControlStateNormal];
    [[UITabBarItem appearance]setTitleTextAttributes:@{UITextAttributeTextColor:[UIColor blackColor]} forState:UIControlStateSelected];
    double version = [[UIDevice currentDevice].systemVersion doubleValue];//判定系统版本
    if(version >= 5.0f){
        [_tabbarController.tabBar setBackgroundImage:[self createImageWithColor:mycolor]];// 设置tabBar背景
        //_tabbarController.tabBar.selectionIndicatorImage = [[UIImage imageNamed:@"7-1.png"] scaleToSize:CGSizeMake(76, 45)];// 设置tabBarItem选中的背景
    } else {
        _tabbarController.tabBar.layer.contents = (id)[[UIImage imageNamed:@"b.png"] scaleToSize:CGSizeMake(320, 49)].CGImage;
    }
    
    // 首页
    HomeViewController *home = [[HomeViewController alloc] init];
    UINavigationController *homeNav = [[UINavigationController alloc] initWithRootViewController:home];
    
    if (BYT_IOS7) {
        homeNav.navigationBar.barTintColor = mycolor;
        homeNav.navigationBar.translucent = NO;
        homeNav.tabBarItem = [[UITabBarItem alloc]initWithTitle:MyLocal(@"车辆列表") image:[[UIImage imageNamed:@"ic_car.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"ic_car.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    }else{
        [homeNav.navigationBar setBackgroundImage:[[self createImageWithColor:mycolor] scaleToSize:CGSizeMake(320, 44)] forBarMetrics:UIBarMetricsDefault];
        homeNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:MyLocal(@"车辆列表") image:[UIImage imageNamed:@"home.png"] tag:0];
        [homeNav.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"home.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"home.png"]];// 设置tabBarItem选中图片
    }
    
    // 地图，显示当前位置
    MapViewController *map = [[MapViewController alloc] init];
    UINavigationController *mapNav = [[UINavigationController alloc] initWithRootViewController:map];
    
    if (BYT_IOS7) {
        mapNav.navigationBar.barTintColor = mycolor;
        mapNav.navigationBar.translucent = NO;
        mapNav.tabBarItem = [[UITabBarItem alloc]initWithTitle:MyLocal(@"多车监控") image:[[UIImage imageNamed:@"ic_morecar.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"ic_morecar.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    }else{
        [mapNav.navigationBar setBackgroundImage:[[self createImageWithColor:mycolor] scaleToSize:CGSizeMake(320, 44)] forBarMetrics:UIBarMetricsDefault];
        mapNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:MyLocal(@"多车监控") image:[UIImage imageNamed:@"map.png"] tag:1];
        [mapNav.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"map.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"map.png"]];// 设置tabBarItem选中图片
    }
    
    
    // 用户设备报警
    AllAlarmsViewController *allAlarms = [[AllAlarmsViewController alloc] init];
    UINavigationController *allAlarmsNav = [[UINavigationController alloc] initWithRootViewController:allAlarms];
    
    if (BYT_IOS7) {
        allAlarmsNav.navigationBar.barTintColor = mycolor;
        allAlarmsNav.navigationBar.translucent = NO;
        allAlarmsNav.tabBarItem = [[UITabBarItem alloc]initWithTitle:MyLocal(@"车辆报警") image:[[UIImage imageNamed:@"ic_warm.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"ic_warm.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    }else{
        [allAlarmsNav.navigationBar setBackgroundImage:[[self createImageWithColor:mycolor] scaleToSize:CGSizeMake(320, 44)] forBarMetrics:UIBarMetricsDefault];
        allAlarmsNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:MyLocal(@"车辆报警") image:[UIImage imageNamed:@"warn.png"] tag:2];
        [allAlarmsNav.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"warn.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"warn.png"]];// 设置tabBarItem选中图片
    }
    
    // 更多页面
    MoreViewController *more = [[MoreViewController alloc] init];
    UINavigationController *moreNav = [[UINavigationController alloc] initWithRootViewController:more];
    
    if (BYT_IOS7) {
        moreNav.navigationBar.barTintColor = mycolor;
        moreNav.navigationBar.translucent = NO;
        moreNav.tabBarItem = [[UITabBarItem alloc]initWithTitle:MyLocal(@"更多") image:[[UIImage imageNamed:@"more.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"more_select.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    }else{
        [moreNav.navigationBar setBackgroundImage:[[self createImageWithColor:mycolor] scaleToSize:CGSizeMake(320, 44)] forBarMetrics:UIBarMetricsDefault];
        moreNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:MyLocal(@"更多") image:[UIImage imageNamed:@"more.png"] tag:3];
        [moreNav.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"more_select.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"more.png"]];// 设置tabBarItem选中图片
    }
    
    
    _tabbarController.viewControllers = @[homeNav, mapNav, allAlarmsNav/*, moreNav*/];
    
    [self.view addSubview:_tabbarController.view];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeView:) name:@"Tiaozhuan" object:nil];
}
-(void)changeView:(NSNotification *)not

{
    NSString *type = not.userInfo[@"Type"];
    if ([type isEqualToString:@"998"]) {
    ListenViewController *listen = [[ListenViewController alloc] init];
    listen.pushID = not.userInfo[@"ID"];
    UINavigationController *nav =[[UINavigationController alloc]initWithRootViewController:listen];
    [self presentViewController:nav animated:YES completion:nil];
    
    
}if ([type isEqualToString:@"1"]) {
    AlarmViewController *alertVC = [[AlarmViewController alloc]init];
    alertVC.pushID = not.userInfo[@"ID"];
    alertVC.isPresent = YES;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:alertVC];
    [self  presentViewController:nav animated:YES completion:^{
    }];
}
    
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"Notification_Type"]intValue] == 1) {
        _tabbarController.selectedIndex = 2;
    }else {
        _tabbarController.selectedIndex = 0;
    }
}

- (void)tagsAliasCallback:(int)iResCode tags:(NSSet*)tags alias:(NSString*)alias {
    NSLog(@"rescode: %d, \ntags: %@, \nalias: %@\n", iResCode, tags , alias);
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}
@end
