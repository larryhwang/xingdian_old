//
//  MapViewController.m
//  NewGps2012
//
//  Created by TR on 13-3-22.
//  Copyright (c) 2013年 thinkrace. All rights reserved.
//

#import "MapViewController.h"
#import "CustomAnnotation.h"
#import "CustomAnnotitionView.h"
#import "WebService.h"
#import "WebServiceParameter.h"
#import "SBJson.h"
#import "UIImage+Scale.h"
#import "SelectDeviceViewController.h"
#import "DeviceDetailsViewController.h"


@interface MapViewController ()
@property (nonatomic) CLLocationCoordinate2D userCoordinate;
@property (strong, nonatomic) UIButton *carLocationButton;
@property (strong, nonatomic) UIButton *userLocationButton;
@property (strong, nonatomic) UIButton *changeMapTypeButton;
@property (strong, nonatomic) NSTimer *timer;
@end

@implementation MapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = MyLocal(@"多车监控");
        self.humanLocLatLngArray = [[NSMutableArray alloc] initWithCapacity:2];

        //获取Document文件夹下的数据库文件，没有则创建
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *dbPath = [docPath stringByAppendingPathComponent:@"user.db"];
        //获取数据库并打开
        self.DB  = [FMDatabase databaseWithPath:dbPath];
        [_DB open];
        
        
      //  [self getAllDevice];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    IOS7;

    //每10秒钟刷新一次
    
    
    self.LocMapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-49-44)];
    self.LocMapView.delegate = self;
    [self.view addSubview:_LocMapView];
    [_LocMapView setRegion:[_LocMapView regionThatFits:MKCoordinateRegionMake(_userCoordinate, MKCoordinateSpanMake(0.05, 0.05))] animated:NO];
    
    self.hud = [[MBProgressHUD alloc] initWithView:_LocMapView];
    self.hud.color = [UIColor colorWithWhite:0.5 alpha:0.8];
    [self.view addSubview:_hud];
    
    UIButton *lastDeviceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    lastDeviceButton.frame = CGRectMake(10, (VIEW_HEIGHT-64-49)/2, 32, 36);
    [lastDeviceButton setBackgroundImage:[UIImage imageNamed:@"h"] forState:UIControlStateNormal];
    [lastDeviceButton addTarget:self action:@selector(showLastDevice) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:lastDeviceButton];
    
    UIButton *nextDeviceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nextDeviceButton.frame = CGRectMake(274, (VIEW_HEIGHT-64-49)/2, 32, 36);
    [nextDeviceButton setBackgroundImage:[UIImage imageNamed:@"h-1"] forState:UIControlStateNormal];
    [nextDeviceButton addTarget:self action:@selector(showNextDevice) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextDeviceButton];
    
    //切换地图类型
    UIButton *mapTypeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    mapTypeButton.frame = CGRectMake(5, 50, 36, 36);
    [mapTypeButton setBackgroundImage:[UIImage imageNamed:@"standardMap"]forState:UIControlStateNormal];
    [mapTypeButton setBackgroundImage:[UIImage imageNamed:@"hybridMap"]forState:UIControlStateSelected];
    [mapTypeButton addTarget:self action:@selector(changeMapType:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:mapTypeButton];
    //UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(locationCenter:)];
   // [_LocMapView addGestureRecognizer:tap];
    
 //   [self showAllDevice];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.0f target:self selector:@selector(refreshAction) userInfo:nil repeats:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LogOut:) name:@"logout" object:nil];
}


-(void)LogOut:(id)sender
{
    [_timer invalidate];
    _timer = nil;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    //修改导航条上的字体为白色
    if (BYT_IOS7) {
        [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor, nil]];
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

#pragma mark - LoadDeviceData

- (void)getAllDevice
{
    if (!_deviceArray) {
        self.deviceArray = [[NSMutableArray alloc] init];
    }
    [_deviceArray removeAllObjects];
    
    FMResultSet *resultSet = [_DB executeQuery:@"select * from Device"];
    while ([resultSet next]) {
        Device *aDevice = [[Device alloc] init];
        aDevice.deviceID = [resultSet intForColumn:@"deviceID"];
        aDevice.deviceName = [resultSet stringForColumn:@"deviceName"];
        aDevice.groupID = [resultSet intForColumn:@"groupID"];
        aDevice.licencePlate = [resultSet stringForColumn:@"licencePlate"];
        aDevice.status = [resultSet intForColumn:@"status"];
        aDevice.icon = [resultSet stringForColumn:@"icon"];
        aDevice.latitude = [resultSet stringForColumn:@"latitude"];
        aDevice.longitude = [resultSet stringForColumn:@"longitude"];
        aDevice.acc = [resultSet intForColumn:@"acc"];
        aDevice.power = [resultSet intForColumn:@"power"];
        aDevice.isShowAcc = [resultSet intForColumn:@"isShowAcc"];
        aDevice.type = [resultSet stringForColumn:@"type"];
        aDevice.course = [resultSet stringForColumn:@"course"];

        // 只显示运动、静止、离线设备
        if (aDevice.status == 1 || aDevice.status == 2 || aDevice.status == 3) {
            [_deviceArray addObject:aDevice];
        }
    }
}

#pragma mark - ShowAllDevice

- (void)showAllDevice
{
    [_LocMapView removeAnnotations:_LocMapView.annotations];
    NSLog(@"%lu",(unsigned long)_deviceArray.count);
    for (int i = 0; i < _deviceArray.count; i++) {
        Device *aDevice = _deviceArray[i];
        NSString *licencePlate = aDevice.licencePlate;
        if (licencePlate == nil || licencePlate.length == 0) {
            licencePlate = MyLocal(@"暂无");
        }
        
        NSString *accStatus;
        switch (aDevice.acc) {
            case 1:
                accStatus = MyLocal(@"关");
                break;
            case 2:
                accStatus = MyLocal(@"开");
                break;
            default:
                accStatus = MyLocal(@"未检测到ACC");
                break;
        }
        
        NSString *statue;
        switch (aDevice.status) {
            case 0:
                statue = MyLocal(@"未启用");
                break;
            case 1:
                statue = MyLocal(@"运动");
                break;
            case 2:
                statue = MyLocal(@"静止");
                break;
            case 3:
                statue = MyLocal(@"离线");
                break;
            case 4:
                statue = MyLocal(@"欠费");
                break;
            default:
                break;
        }

        CustomAnnotation *annotation = [[CustomAnnotation alloc] initWithCoordinate:CLLocationCoordinate2DMake([aDevice.latitude floatValue], [aDevice.longitude floatValue])];
        annotation.deviceIndex = i;
        annotation.title = [[NSString alloc]initWithFormat:@"%@",aDevice.deviceName];
        annotation.subtitle = [[NSString alloc]initWithFormat:@"%@",statue];
        annotation.course = aDevice.course;
//        NSLog(@"ddd%@",statue);

//        if (aDevice.isShowAcc == 1) {
//            annotation.subtitle = [KAccPrefix stringByAppendingString:accStatus];
//        }
        
//        NSLog(@"ff%@",aDevice.icon);
//        NSLog(@"dd%@",[aDevice.icon substringWithRange:NSMakeRange(0, 2)]);
//        annotation.carIcon = [NSString stringWithFormat:@"car_%@", aDevice.icon];
//        [aDevice.icon substringWithRange:NSMakeRange(0, 2)];
        
        if ([aDevice.icon isEqualToString:@"23"]) {
            if (aDevice.status == 1 || aDevice.status == 2) {
                annotation.carIcon = @"car2";
            } else {
                annotation.carIcon = @"TRCOnline_2-22";
            }
        } else {
            if (aDevice.status == 1 || aDevice.status == 2) {
                annotation.carIcon = @"car1";
            } else {
                annotation.carIcon = @"TRCOnline_3-8";
            }
        }

        if (i == _currentShowBubbleIndex) {
            annotation.showCallout = YES;
            // 移动地图使当前设备始终居中显示
            [_LocMapView setCenterCoordinate:annotation.coordinate animated:NO];
        } else {
            annotation.showCallout = NO;
        }
        
//        if (i==0) {
//            annotation.showCallout = YES;
//        }else{
//            annotation.showCallout = NO;
//        }
        
        [_LocMapView addAnnotation:annotation];       
    }
    
    if (_hud) {
        [_hud hide:YES];
    }
}

- (void)selectAnnotation:(NSInteger)index
{
    NSLog(@"index是%ld",(long)index);
    for (CustomAnnotation *annaotation in _LocMapView.annotations) {
        if (annaotation.deviceIndex == index) {
            [_LocMapView selectAnnotation:annaotation animated:NO];
           // [_LocMapView setCenterCoordinate:annaotation.coordinate];
            NSLog(@"%f---%f---%ld",annaotation.coordinate.latitude,annaotation.coordinate.
                  longitude,(long)annaotation.deviceIndex);
            NSLog(@"%f--center--%f",_LocMapView.centerCoordinate.latitude,_LocMapView.centerCoordinate.longitude);
        }
    }
}
- (void)changeMapType:(UIButton *)button
{
    button.selected = !button.selected;
    if (button.selected) {
        [_LocMapView setMapType:MKMapTypeHybrid];
    } else {
        [_LocMapView setMapType:MKMapTypeStandard];
    }
    
    [self refresh];
}

- (void)showLastDevice
{
    if (_deviceArray.count == 0) {
        return;
    }
    self.currentShowBubbleIndex = (_currentShowBubbleIndex - 1 + _deviceArray.count) % _deviceArray.count;
   // [self showAllDevice];
    [self selectAnnotation:self.currentShowBubbleIndex];
}

- (void)showNextDevice
{
    if (_deviceArray.count == 0) {
        return;
    }
    self.currentShowBubbleIndex = (_currentShowBubbleIndex + 1) % _deviceArray.count;
   // [self showAllDevice];
    [self selectAnnotation:self.currentShowBubbleIndex];
}

- (void)showDeviceDetail
{
    Device *theDevice = _deviceArray[_currentShowBubbleIndex];
    NSLog(@"%lu-----------------",(unsigned long)_deviceArray.count);
    int deviceID = theDevice.deviceID;
    
//    [USER_DEFAULT setInteger:deviceID forKey:@"DeviceID"];
    
    NSString *deviceName = theDevice.deviceName;
    NSString *licencePlate = theDevice.licencePlate;
    NSString *carIcon = theDevice.icon;
    if (theDevice.status == 1 || theDevice.status == 2) {
        carIcon = [NSString stringWithFormat:@"car%@", carIcon];
    } else {
        carIcon = [NSString stringWithFormat:@"offline%@", carIcon];
    }
    int power = theDevice.power;
    int isShowAcc = theDevice.isShowAcc;
    NSString *type = theDevice.type;
    
    [USER_DEFAULT setInteger:deviceID forKey:@"DeviceID"];
    [USER_DEFAULT setObject:deviceName forKey:@"DeviceName"];
    [USER_DEFAULT setObject:licencePlate forKey:@"LicencePlate"];
    [USER_DEFAULT setObject:carIcon forKey:@"CarAlarmIcon"];
    [USER_DEFAULT setInteger:power forKey:@"Power"];
    [USER_DEFAULT setInteger:isShowAcc forKey:@"IsShowAcc"];
    [USER_DEFAULT setObject:type forKey:@"Type"];
    
    SelectDeviceViewController *deviceViewController = [[SelectDeviceViewController alloc] init];
    deviceViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:deviceViewController animated:YES];
}

- (void)showDeviceInfo
{
    Device *theDevice = _deviceArray[_currentShowBubbleIndex];
//
    int deviceID = theDevice.deviceID;
    [USER_DEFAULT setInteger:deviceID forKey:@"DeviceID"];

    DeviceDetailsViewController *details = [[DeviceDetailsViewController alloc] init];
    details.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:details animated:YES];
}

- (void)refreshAction
{
    if (_hud) {
        [_hud show:YES];
    }
    
    WebService *webService = [WebService newWithWebServiceAction:@"GetDeviceList" andDelegate:self];
    WebServiceParameter *getDeviceParameter1 = [WebServiceParameter newWithKey:@"ID" andValue:[USER_DEFAULT objectForKey:@"ReturnID"]];
    WebServiceParameter *getDeviceParameter2 = [WebServiceParameter newWithKey:@"PageNo" andValue:@"1"];
    WebServiceParameter *getDeviceParameter3 = [WebServiceParameter newWithKey:@"PageCount" andValue:@"9999"];
    WebServiceParameter *getDeviceParameter4 = [WebServiceParameter newWithKey:@"TypeID" andValue:[NSString stringWithFormat:@"%ld",(long)[USER_DEFAULT integerForKey:@"LoginType"]]];
    WebServiceParameter *getDeviceParameter5 = [WebServiceParameter newWithKey:@"IsAll" andValue:@"true"];
    WebServiceParameter *getDeviceParameter6 = [WebServiceParameter newWithKey:@"MapType" andValue:@"Google"];
    
    webService.webServiceParameter = @[getDeviceParameter1, getDeviceParameter2, getDeviceParameter3, getDeviceParameter4, getDeviceParameter5, getDeviceParameter6];
    [webService getWebServiceResult:@"GetDeviceListResult"];
}

- (void)refresh
{
    [self getAllDevice];
    [self showAllDevice];
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
//    CustomAnnotation *custom = (CustomAnnotation*)view.annotation;
    
    if ([view.annotation isKindOfClass:[CustomAnnotation class]]) {
        CustomAnnotation *custom = (CustomAnnotation*)view.annotation;
        self.currentShowBubbleIndex = custom.deviceIndex;
        custom.showCallout = YES;
        [_LocMapView setCenterCoordinate:custom.coordinate];
    }
}
- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    if ([view.annotation isKindOfClass:[CustomAnnotation class]]) {
        CustomAnnotation *custom = (CustomAnnotation*)view.annotation;
        custom.showCallout = NO;
    }
}
// 在地图上展示不同的Annotation
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[CustomAnnotation class]]) {
        CustomAnnotation *customAnnotation = (CustomAnnotation *)annotation;
        
        static NSString *identifier = @"CustomAnnotation";
        MKAnnotationView *pinView = [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (pinView == nil) {
            pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            
        }
        
        pinView.canShowCallout = YES;
        pinView.calloutOffset = CGPointMake(3, 5);
        pinView.selected = customAnnotation.showCallout;
        
        UIImage *carImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", customAnnotation.carIcon]];
        
        pinView.image = carImage;
        
        //气泡左边的按钮 设备详情
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        leftButton.frame = CGRectMake(108, 8, 25, 25);
        [leftButton setBackgroundImage:[UIImage imageNamed:@"detail"] forState:UIControlStateNormal];
        [leftButton setBackgroundImage:[UIImage imageNamed:@"detail-h"] forState:UIControlStateHighlighted];
        [leftButton addTarget:self action:@selector(showDeviceInfo) forControlEvents:UIControlEventTouchUpInside];
        
        pinView.leftCalloutAccessoryView = leftButton;
        
        //气泡右边的按钮
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        rightButton.frame = CGRectMake(112, 50, 16, 25);
        [rightButton setBackgroundImage:[UIImage imageNamed:@"TRCOnline_2c-7.png"] forState:UIControlStateNormal];
        [rightButton addTarget:self action:@selector(rightButtonClick) forControlEvents:UIControlEventTouchUpInside];
        
        pinView.rightCalloutAccessoryView = rightButton;
        
        return pinView;
    }
    return nil;
}

-(void)rightButtonClick{
    
//    DeviceGroup *list = _tableDataLists[indexPath.section];
//    Device *theDevice = list.devicesByGroup[indexPath.row];
    Device *theDevice = _deviceArray[_currentShowBubbleIndex];
    int deviceID = theDevice.deviceID;
    
    NSString *deviceName = theDevice.deviceName;
    NSString *licencePlate = theDevice.licencePlate;
    NSString *carIcon = theDevice.icon;
    if (theDevice.status == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"车辆未启用" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    //    if (theDevice.status == 1 || theDevice.status == 2) {
    //        carIcon = [NSString stringWithFormat:@"car%@", carIcon];
    //    } else {
    //        carIcon = [NSString stringWithFormat:@"offline%@", carIcon];
    //    }
 
    switch (theDevice.status) {
        case 0:

            //aDevice.icon  offline_23_45
            if ([theDevice.icon intValue]==23) {
                //灰色摩托车
                carIcon = @"TRCOnline_2-22";
            }else{
                //灰色汽车
                carIcon = @"TRCOnline_2-9";
            }
            
            break;
        case 1:
            //aDevice.icon  car_23_90

            if ([theDevice.icon intValue]==23) {
                //绿色摩托车
                carIcon = @"TRCOnline_2-21";
            }else{
                //绿色汽车
                carIcon = @"TRCOnline_2-8";

            }
            break;
        case 2:

            if ([theDevice.icon intValue]==23) {
                //橙色摩托车
                carIcon = @"TRCOnline_2-20";
            }else{
                //橙色汽车
                carIcon = @"TRCOnline_2-7";
            }
            break;
        case 3:
            
            if ([theDevice.icon intValue]==23) {
                //灰色摩托车
                carIcon = @"TRCOnline_2-22";
            }else{
                //灰色汽车
                carIcon = @"TRCOnline_2-9";
            }
            break;
        case 4:
            if ([theDevice.icon intValue]==23) {
                //灰色摩托车
                carIcon = @"TRCOnline_2-22";
            }else{
                //灰色汽车
               carIcon = @"TRCOnline_2-9";
            }
            break;
            
        default:
            break;
    }

    int power = theDevice.power;
    int isShowAcc = theDevice.isShowAcc;
    NSString *type = theDevice.type;
    
    [USER_DEFAULT setInteger:deviceID forKey:@"DeviceID"];
    [USER_DEFAULT setObject:deviceName forKey:@"DeviceName"];
    [USER_DEFAULT setObject:licencePlate forKey:@"LicencePlate"];
    [USER_DEFAULT setObject:carIcon forKey:@"CarAlarmIcon"];
    [USER_DEFAULT setInteger:power forKey:@"Power"];
    [USER_DEFAULT setInteger:isShowAcc forKey:@"IsShowAcc"];
    [USER_DEFAULT setObject:type forKey:@"Type"];
    
//    Device *theDevice = _deviceArray[_currentShowBubbleIndex];
//    
//    int deviceID = theDevice.deviceID;
    [USER_DEFAULT setInteger:deviceID forKey:@"DeviceID"];
    SelectDeviceViewController *deviceViewController = [[SelectDeviceViewController alloc] init];
    deviceViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:deviceViewController animated:YES];
}

// 默认显示Callout
- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    for (MKPinAnnotationView *pinView in views) {
        if (pinView.selected) {
            [_LocMapView selectAnnotation:pinView.annotation animated:YES];
        }
    }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    self.userCoordinate = userLocation.coordinate;
}

//----------------WebServiceProtocol-----------------------

#pragma mark - WebServiceProtocol

- (void)WebServiceGetCompleted:(id)theWebService
{
    
    
    if ([[theWebService webServiceResult] length] > 0) {
//        SBJsonParser *parser = [[SBJsonParser alloc] init];
//        NSError *error = nil;
//        // 解析成json数据
//        id object = [parser objectWithString:[theWebService soapResults] error:&error];
        NSString *str = [theWebService soapResults];
        str = [str stringByReplacingOccurrencesOfString:@"	" withString:@""];
        id object = [str objectFromJSONString];
        if (object) {
            // 获得状态
            int state = [[object objectForKey:@"state"] intValue];
            if (state == 0) {
                NSArray *allDevice = [object objectForKey:@"arr"];
                for (id aDevice in allDevice) {
                    int deviceID = [[aDevice objectForKey:@"id"] intValue];
                    NSString *name = [aDevice objectForKey:@"name"];
                    int groupID = [[aDevice objectForKey:@"groupID"] intValue];
                    NSString *licencePlate = [aDevice objectForKey:@"car"];
                    int status = [[aDevice objectForKey:@"status"] intValue];
                    NSString *icon = [aDevice objectForKey:@"icon"];
                    NSString *latitude = [aDevice objectForKey:@"latitude"];
                    NSString *longitude = [aDevice objectForKey:@"longitude"];
                    int acc = [[aDevice objectForKey:@"acc"] intValue];
                    int power = [[aDevice objectForKey:@"isGT08"] intValue];
                    int isShowAcc = [[aDevice objectForKey:@"isShowAcc"] intValue];
                    NSString *type = [aDevice objectForKey:@"type"];
                    NSString *course = [aDevice objectForKey:@"course"];
                    
                    [_DB executeUpdate:@"update Device set deviceName = ?, groupID = ?, licencePlate = ?, status = ?, icon = ?, latitude = ?, longitude = ?, acc = ?, power = ?, isShowAcc = ?, type = ?, course = ? where deviceID = ?", name, [NSNumber numberWithInt:groupID], licencePlate, [NSNumber numberWithInt:status], icon, latitude, longitude, [NSNumber numberWithInt:acc], [NSNumber numberWithInt:power], [NSNumber numberWithInt:isShowAcc], type, course, [NSNumber numberWithInt:deviceID]];
                }
                [self performSelectorOnMainThread:@selector(refresh) withObject:nil waitUntilDone:NO];
            }
        }
    }
}

- (void)WebServiceGetError:(id)theWebService type:(WebServiceFailureType)failureType
{
    if (_hud) {
        [_hud hide:YES];
    }
    
    switch (failureType) {
        case WebServiceTimeOut:
            break;
        case WebServiceInitFailed:
            break;
        case WebServiceConnectFailed:
            break;
        default:
            break;
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
