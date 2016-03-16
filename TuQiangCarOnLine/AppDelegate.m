//
//  AppDelegate.m
//  NewGps2012
//
//  Created by TR on 13-1-28.
//  Copyright (c) 2013年 thinkrace. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"
#import "APService.h"

#import "TabbarViewController.h"
#import "ListenViewController.h"
#import "AlarmViewController.h"

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    //登录口
    ViewController *VC = [[ViewController alloc] init];
    UINavigationController *NC = [[UINavigationController alloc]initWithRootViewController:VC];
    [NC setNavigationBarHidden:YES];
    
    self.window.rootViewController = NC;
    
    
//    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
//    //已连接
//    [defaultCenter addObserver:self selector:@selector(networkDidSetup:) name:kAPNetworkDidSetupNotification object:nil];
//    //未连接
//    [defaultCenter addObserver:self selector:@selector(networkDidClose:) name:kAPNetworkDidCloseNotification object:nil];
//    //已注册
//    [defaultCenter addObserver:self selector:@selector(networkDidRegister:) name:kAPNetworkDidRegisterNotification object:nil];
//    //已登录
//    [defaultCenter addObserver:self selector:@selector(networkDidLogin:) name:kAPNetworkDidLoginNotification object:nil];
//    //收到消息(非APNS)
//    [defaultCenter addObserver:self selector:@selector(networkDidReceiveMessage:) name:kAPNetworkDidReceiveMessageNotification object:nil];
//    
    
    [self.window makeKeyAndVisible];
    
    
    //注册通知
//    [APService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        NSMutableSet *categories = [NSMutableSet set];
        UIMutableUserNotificationCategory *category = [[UIMutableUserNotificationCategory alloc] init];
        category.identifier = @"identifier";
        UIMutableUserNotificationAction *action = [[UIMutableUserNotificationAction alloc] init];
        action.identifier = @"test2";
        action.title = @"test";
        action.activationMode = UIUserNotificationActivationModeBackground;
        action.authenticationRequired = YES;
        //YES显示为红色，NO显示为蓝色
        action.destructive = NO;
        NSArray *actions = @[ action ];
        [category setActions:actions forContext:UIUserNotificationActionContextMinimal];
        [categories addObject:category];
        [APService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)                      categories:categories];
    }else {
        [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)                      categories:nil];
    }

    
    
    
    [APService setupWithOption:launchOptions];
    
    
    //应用未打开时进行跳转
    NSDictionary *remoteNotification = [launchOptions objectForKey: UIApplicationLaunchOptionsRemoteNotificationKey];
    
    [[NSUserDefaults standardUserDefaults]setObject:[remoteNotification objectForKey:@"Type"] forKey:@"Notification_Type"];
//    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(changeLLL) userInfo:nil repeats:YES];
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [application setApplicationIconBadgeNumber:0];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
     [APService setAlias:@"" callbackSelector:nil object:nil];
    
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [APService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *) error {
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [APService handleRemoteNotification:userInfo];
    NSString *n_content = [[userInfo objectForKey:@"aps"]objectForKey:@"alert"];
    BOOL isFront    =  application.applicationState == UIApplicationStateActive;
    BOOL isinListen = [[USER_DEFAULT objectForKey:@"isInListenVC"] isEqualToString:@"1"];
    BOOL isinAlert  = [[USER_DEFAULT objectForKey:@"isInAlertVC"] isEqualToString:@"1"];
    
    NSString *deviceID = userInfo[@"DeviceID"]?:@"";
    
    if ([userInfo[@"Type"] isEqualToString:@"998"]) {
        if (isinListen) {
            //发通知
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshList" object:nil userInfo:userInfo];
            
        }else{
            if (isFront) {
                //弹框
                _ID = deviceID;
                _alertView1 = [[UIAlertView alloc]initWithTitle:MyLocal(@"通知") message:n_content delegate:self cancelButtonTitle:MyLocal(@"我知道了") otherButtonTitles:nil, nil];
                [_alertView1 show];
                
            }else{
                //直接跳转
                [[NSNotificationCenter defaultCenter] postNotificationName:@"Tiaozhuan" object:nil userInfo:[NSDictionary dictionaryWithObjects:@[userInfo[@"Type"],deviceID] forKeys:@[@"Type",@"ID"]]];
            }
        }
        
    }else if ([userInfo[@"Type"] isEqualToString:@"1"]){
        if (isinAlert) {
            //发通知
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshAlertList" object:nil userInfo:userInfo];
            
        }else{
            if (isFront) {
                //弹框
                _ID = deviceID;
                if (!_alertView2 ) {
                    _alertView2 = [[UIAlertView alloc]initWithTitle:MyLocal(@"通知") message:n_content delegate:self cancelButtonTitle:MyLocal(@"我知道了") otherButtonTitles:nil, nil];
                    [_alertView2 show];
                }
            }else{
                //直接跳转
                [[NSNotificationCenter defaultCenter] postNotificationName:@"Tiaozhuan" object:nil userInfo:[NSDictionary dictionaryWithObjects:@[userInfo[@"Type"],deviceID] forKeys:@[@"Type",@"ID"]]];
            }
        }
        
        
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView == _alertView1 && buttonIndex==0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Tiaozhuan" object:nil userInfo:[NSDictionary dictionaryWithObjects:@[@"998",_ID] forKeys:@[@"Type",@"ID"]]];
    }else if (alertView == _alertView2 && buttonIndex == 0){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Tiaozhuan" object:nil userInfo:[NSDictionary dictionaryWithObjects:@[@"1",_ID] forKeys:@[@"Type",@"ID"]]];
    }
}
//
////avoid compile error for sdk under 7.0
//#ifdef __IPHONE_7_0
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [APService handleRemoteNotification:userInfo];
    
    
     NSString *n_content = [[userInfo objectForKey:@"aps"]objectForKey:@"alert"];
    BOOL isFront    =  application.applicationState == UIApplicationStateActive;
    BOOL isinListen = [[USER_DEFAULT objectForKey:@"isInListenVC"] isEqualToString:@"1"];
    BOOL isinAlert  = [[USER_DEFAULT objectForKey:@"isInAlertVC"] isEqualToString:@"1"];

    NSString *deviceID = userInfo[@"DeviceID"]?:@"";
    
    if ([userInfo[@"Type"] isEqualToString:@"998"]) {
        if (isinListen) {
            //发通知
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshList" object:nil userInfo:userInfo];
            
        }else{
            if (isFront) {
                //弹框
                    _ID = deviceID;
                    _alertView1 = [[UIAlertView alloc]initWithTitle:MyLocal(@"通知") message:n_content delegate:self cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:NSLocalizedString(@"取消", nil), nil];
                    [_alertView1 show];
                
            }else{
                 //直接跳转
                [[NSNotificationCenter defaultCenter] postNotificationName:@"Tiaozhuan" object:nil userInfo:[NSDictionary dictionaryWithObjects:@[userInfo[@"Type"],deviceID] forKeys:@[@"Type",@"ID"]]];
            }
        }
        
    }else if ([userInfo[@"Type"] isEqualToString:@"1"]){
        if (isinAlert) {
            //发通知
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshAlertList" object:nil userInfo:userInfo];
            
        }else{
            if (isFront) {
                //弹框
                _ID = deviceID;
                if (!_alertView2 ) {
                    _alertView2 = [[UIAlertView alloc]initWithTitle:MyLocal(@"通知") message:n_content delegate:self cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:NSLocalizedString(@"取消", nil), nil];
                    [_alertView2 show];
                }
            }else{
                //直接跳转
                [[NSNotificationCenter defaultCenter] postNotificationName:@"Tiaozhuan" object:nil userInfo:[NSDictionary dictionaryWithObjects:@[userInfo[@"Type"],deviceID] forKeys:@[@"Type",@"ID"]]];
            }
        }
        

    }
    completionHandler(UIBackgroundFetchResultNoData);
}
//#endif

#pragma mark -

- (void)networkDidSetup:(NSNotification *)notification {
    [_infoLabel setText:@"已连接"];
}

- (void)networkDidClose:(NSNotification *)notification {
    [_infoLabel setText:@"未连接。。。"];
}

- (void)networkDidRegister:(NSNotification *)notification {
    [_infoLabel setText:@"已注册"];
}

- (void)networkDidLogin:(NSNotification *)notification {
    [_infoLabel setText:@"已登录"];
}

- (void)networkDidReceiveMessage:(NSNotification *)notification {
    NSDictionary * userInfo = [notification userInfo];
    NSString *title = [userInfo valueForKey:@"title"];
    NSString *content = [userInfo valueForKey:@"content"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    
    [_infoLabel setText:[NSString stringWithFormat:@"收到消息\ndate:%@\ntitle:%@\ncontent:%@", [dateFormatter stringFromDate:[NSDate date]],title,content]];
    
}



//- (void)tagsAliasCallback:(int)iResCode tags:(NSSet*)tags alias:(NSString*)alias {
//    NSLog(@"rescode: %d, \ntags: %@, \nalias: %@\n", iResCode, tags , alias);
//}

@end
