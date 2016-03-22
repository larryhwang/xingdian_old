//
//  TrackingViewController.m
//  NewGps2012
//
//  Created by TR on 13-2-19.
//  Copyright (c) 2013年 thinkrace. All rights reserved.
//

//本页面用于描述实时追踪

#import "TrackingViewController.h"
#import "WebServiceParameter.h"
#import "SBJson.h"
#import "CustomAnnotitionView.h"
#import "DeviceTrackingState.h"
#import "MBProgressHUD.h"
#import "DeviceDetailsViewController.h"
#import "NavigationViewController.h"
#import "LMHttpPost.h"
#import "SVProgressHUD.h"
#import "HYAlertView.h"

#define WebServiceTag_GetTracking 1
#define WebServiceTag_GetAddress 2

@interface TrackingViewController () <MKMapViewDelegate,CLLocationManagerDelegate,HYAlertViewDelegate>

//@property (strong, nonatomic) UIButton *carLocationButton;
//@property (strong, nonatomic) UIButton *userLocationButton;
@property (strong, nonatomic) UIButton *changLocationButton;
@property (nonatomic) CLLocationCoordinate2D userCoordinate;
@property (strong, nonatomic) MBProgressHUD *hud;

@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) UITextField *textField;
@property (strong, nonatomic) UIButton    *navagtionButton;
@property (nonatomic, assign) NSInteger   isOne;
@property (nonatomic, strong) NSTimer     *timer;
@property (nonatomic, assign) bool        showCallout;
@property (nonatomic, strong) NSString    *responseStr;
@property (nonatomic, strong) NSTimer     *responseTimer;
@property (nonatomic, assign) NSInteger   count;
@end

@implementation TrackingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
       
   
        self.isShowHumanLocation = NO;
        _showCallout = YES;
        self.locations = [[NSMutableArray alloc] init];
        self.trackingStates = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{UITextAttributeTextColor:mycolor} forState:UIControlStateSelected];
    
   // self.navigationItem.rightBarButtonItem
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (BYT_IOS7) {
        self.trackingMapView = [[MKMapView alloc] initWithFrame:CGRectMake(0,0, VIEW_WIDTH, VIEW_HEIGHT-44-49-20)];
    }else{
        self.trackingMapView = [[MKMapView alloc] initWithFrame:CGRectMake(0,0, VIEW_WIDTH, VIEW_HEIGHT-44-49)];
    }
    self.trackingMapView.delegate = self;
    self.trackingMapView.mapType = MKMapTypeStandard;
    self.trackingMapView.showsUserLocation = YES;
    MKCoordinateRegion region = {{0, 0}, {0.05, 0.05}};
    [_trackingMapView setRegion:region animated:YES];
    [self.view addSubview:_trackingMapView];
    
    self.locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    if(VERSION>=8.0){
        [_locationManager requestAlwaysAuthorization];//始终
//        [_locationManager requestWhenInUseAuthorization];//使用期间//or
    }
    
    //顶部导航栏的地址
    self.address = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, VIEW_WIDTH , 35)];
    self.address.lineBreakMode = NSLineBreakByCharWrapping;
    self.address.numberOfLines = 0;
    self.address.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
    self.address.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    self.address.textColor = [UIColor blackColor];
    self.address.font = [UIFont systemFontOfSize:12.0];
    [self.view addSubview:_address];
    
    //切换地图类型
    UIButton *mapTypeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    mapTypeButton.frame = CGRectMake(5, 50, 36, 36);
    [mapTypeButton setBackgroundImage:[UIImage imageNamed:@"standardMap"]forState:UIControlStateNormal];
    [mapTypeButton setBackgroundImage:[UIImage imageNamed:@"hybridMap"]forState:UIControlStateSelected];
    [mapTypeButton addTarget:self action:@selector(changeMapType:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:mapTypeButton];
    
//    self.carLocationButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    _carLocationButton.frame = CGRectMake(5, VIEW_HEIGHT-280, 36, 36);
//    [_carLocationButton setBackgroundImage:[UIImage imageNamed:@"carLoc"] forState:UIControlStateNormal];
//    [_carLocationButton addTarget:self action:@selector(showAnnotation) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:_carLocationButton];
//    
//    self.userLocationButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    _userLocationButton.frame = CGRectMake(5, VIEW_HEIGHT-230, 36, 36);
//    [_userLocationButton setBackgroundImage:[UIImage imageNamed:@"userLoc"] forState:UIControlStateNormal];
//    [_userLocationButton addTarget:self action:@selector(showHumanLocation) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:_userLocationButton];
    
    self.changLocationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _changLocationButton.frame = CGRectMake(5, VIEW_HEIGHT-180, 36, 36);
    [_changLocationButton setBackgroundImage:[UIImage imageNamed:@"userLoc"] forState:UIControlStateNormal];
    [_changLocationButton setBackgroundImage:[UIImage imageNamed:@"carLoc"] forState:UIControlStateSelected];
    [_changLocationButton addTarget:self action:@selector(showLocation) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_changLocationButton];
    
    //导航按键
    self.navagtionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _navagtionButton.frame = CGRectMake(5, VIEW_HEIGHT-230, 36, 36);
    [_navagtionButton setBackgroundImage:[UIImage imageNamed:@"daohang"] forState:UIControlStateNormal];
    [_navagtionButton addTarget:self action:@selector(navgationAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_navagtionButton];
    
    //添加缩放按钮
    UIButton *plusBtn=[[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width-47, self.view.frame.size.height-200, 35, 35)];
    [plusBtn setBackgroundImage:[UIImage imageNamed:@"fangda.png"] forState:UIControlStateNormal];
    plusBtn.adjustsImageWhenHighlighted=NO;
    [plusBtn addTarget:self action:@selector(fangda) forControlEvents:UIControlEventTouchUpInside];
    [self.trackingMapView addSubview:plusBtn];
    UIButton *minBtn=[[UIButton alloc]initWithFrame:CGRectMake(plusBtn.frame.origin.x, plusBtn.frame.origin.y+37, 35, 35)];
    [minBtn setBackgroundImage:[UIImage imageNamed:@"suoxiao.png"] forState:UIControlStateNormal];
    minBtn.adjustsImageWhenHighlighted=NO;
    [minBtn addTarget:self action:@selector(suoxiao) forControlEvents:UIControlEventTouchUpInside];
    [self.trackingMapView addSubview:minBtn];
    UIImageView *lineView=[[UIImageView alloc]initWithFrame:CGRectMake(plusBtn.frame.origin.x, plusBtn.frame.origin.y+35, 34, 2)];
    lineView.image=[UIImage imageNamed:@"zoomline.png"];
    [self.trackingMapView addSubview:lineView];
    
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(getDeviceLocation) userInfo:nil repeats:YES];
    
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    self.hud.color = [UIColor colorWithWhite:0.5 alpha:0.8];
    [self.view addSubview:_hud];
    [_hud show:YES];
    
    [self ET500SSetting];
    
    [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(getDeviceLocation) userInfo:nil repeats:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LogOut:) name:@"logout" object:nil];
//    [self getDeviceLocation];
}
#pragma mark -GT500S指令添加  ---------华丽的分割线----------
- (void)ET500SSetting
{
     NSString *type = [USER_DEFAULT objectForKey:@"Type"];
    if ([type isEqualToString:@"GT500S"]) {
        UIButton *immediateBtn = [[UIButton alloc] initWithFrame:CGRectMake(1.5, 96, 41, 41)];
        [immediateBtn setImage:[UIImage imageNamed:@"locationImmediately"] forState:UIControlStateNormal];
        [immediateBtn addTarget:self action:@selector(ImmediatelyLocation) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:immediateBtn];
    }
}
- (void)ImmediatelyLocation
{
    
    HYAlertView *TimeAlert = [[HYAlertView alloc]initWithWidth:270 WithTitle:nil];
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TimeAlert.width, 50)];
    view.backgroundColor = [UIColor whiteColor];
    
    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(30, 10, 80, 30)];
    label1.text = NSLocalizedString(@"持续定位", nil);
    label1.backgroundColor = [UIColor clearColor];
    [view addSubview:label1];
    
    //SOS文本框
    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(label1.frame.origin.x+label1.frame.size.width, 10, 100, 30)];
    _textField.placeholder = @"5~300";
    _textField.text = @"";
    _textField.keyboardType = UIKeyboardTypeNumberPad;
    _textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _textField.borderStyle = UITextBorderStyleRoundedRect;
    [view addSubview:_textField];
    
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(_textField.frame.origin.x+_textField.frame.size.width, 10, 60, 30)];
    label2.text = NSLocalizedString(@"分钟", nil);
    label2.backgroundColor = [UIColor clearColor];
    [view addSubview:label2];
    TimeAlert.delegate = self;
    [TimeAlert Show:view];
    
}
- (void)didSelectedOK:(HYAlertView *)alertView
{
    if (0<[self.textField.text intValue]&&[self.textField.text intValue]<=4) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"请输入合法的数值", nil) duration:1.5];
        return;
    }
    if([self.textField.text intValue]>300){
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"请输入合法的数值", nil) duration:1.5];
        return;
    }
    if ([self.textField.text integerValue] == 0) {
        if ([self.textField.text  isEqualToString:@""]) {
            NSLog(@"hhehehehe");
        }else if ([self.textField.text isEqualToString:@"0"]) {
            NSLog(@"卧槽，有飞碟");
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"请输入合法的数值", nil) duration:1.5];
            return;
        }
    }
   
    
    NSString *param1 = @"";
    if (self.textField.text.length == 0) {
        param1 = @"5";
    }else {
        param1 = self.textField.text;
    }
    NSDictionary *param = [NSDictionary dictionaryWithObjects:@[[USER_DEFAULT objectForKey:@"DeviceID"],@"27",param1,@"",@""] forKeys:@[@"deviceID",@"Type",@"Param1",@"Param2",@"Param3"]];
    LMHttpPost   *post  = [[LMHttpPost alloc]init];
    [post getResponseWithName:@"SendDeviceCommand" parameters:param success:^(id responseObject) {
        NSString *Str = responseObject;
        NSLog(@"SendDeviceCommandReturn----%@----",Str);
        if ([Str isEqualToString:@"1001"]) {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"设备不在线", nil) duration:1.5];
        }else if([Str isEqualToString:@"1002"]){
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"ID无效", nil) duration:1.5];
            
        }else if([Str isEqualToString:@"2001"]){
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"设备无返回", nil) duration:1.5];
            
        }else{
            _responseStr = responseObject;
            if (_responseTimer) {
                [_responseTimer invalidate];
                _responseTimer = nil;
            }
            _count = 0;
            [self performSelector:@selector(getResponse) withObject:nil afterDelay:0.1];
            _responseTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(getResponse) userInfo:nil repeats:YES];
        }
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"网络错误", nil) duration:2];
    }];
}
- (void) getResponse{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"正在GPS定位中", nil)];
    NSLog(@"-----响应时间%ld",(long)_count);
    if (_count>30) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"设备无响应", nil) duration:2];
        [_responseTimer invalidate];
        _responseTimer = nil;
        _count = 0;
        return;
    }
    NSDictionary *param  = [NSDictionary dictionaryWithObject:_responseStr forKey:@"CommandID"];
    LMHttpPost   *post   = [[LMHttpPost alloc] init];
    [post getResponseWithName:@"GetResponse" parameters:param success:^(id responseObject) {
        
        NSLog(@"GetResponseReturn>>>>>>>>>>%@",responseObject);
        if ([responseObject isEqualToString:@"OK!"]) {
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"GPS定位正在打开", nil) duration:2];
            [_responseTimer invalidate];
            _responseTimer = nil;
            _count = 0;
        }
            
    } failure:^(NSError *error) {
        [_responseTimer invalidate];
        _responseTimer = nil;
        _count = 0;
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"网络错误", nil) duration:2];
    }];
    _count+= 5;
    
}
#pragma mark -------华丽的分割线-----------
-(void)LogOut:(id)sender
{
    [_timer invalidate];
    _timer = nil;
}

-(void)fangda
{
    MKCoordinateRegion region=self.trackingMapView.region;
    region.span.latitudeDelta*=0.8;
    region.span.longitudeDelta*=0.8;
    [self.trackingMapView setRegion:region];
    
}
-(void)suoxiao
{
    MKCoordinateRegion region=self.trackingMapView.region;
    region.span.latitudeDelta /=0.8;
    region.span.longitudeDelta /=0.8;
    if (region.span.longitudeDelta>360||region.span.latitudeDelta>180) {
        region=self.trackingMapView.region;
    }
    [self.trackingMapView setRegion:region];
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_timer invalidate];
    _timer = nil;
    [SVProgressHUD dismiss];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            if ([manager respondsToSelector:@selector(requestAlwaysAuthorization)])
            {
                [manager requestWhenInUseAuthorization];
            }
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Target Action

-(void)changeMapType:(UIButton *)button
{
    button.selected = !button.selected;
    if (button.selected) {
        [_trackingMapView setMapType:MKMapTypeHybrid];
    } else {
        [_trackingMapView setMapType:MKMapTypeStandard];
    }
}

- (void)didSelectAnnotation
{
    DeviceDetailsViewController *detail = [[DeviceDetailsViewController alloc] init];
    [self.navigationController pushViewController:detail animated:YES];
}

#pragma mark - Unpublic

- (void)loadRoute
{
    MKMapPoint *pointArr = malloc(sizeof(MKMapPoint) * _locations.count);
    // 画出设备位置点
    for (int idx = 0; idx < _locations.count; idx++) {
        NSString *currentPointString = _locations[idx];
        NSArray *latLonArr = [currentPointString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
        CLLocationDegrees latitude  = [[latLonArr objectAtIndex:0] doubleValue];// 纬度
        CLLocationDegrees longitude = [[latLonArr objectAtIndex:1] doubleValue];// 经度
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        MKMapPoint point = MKMapPointForCoordinate(coordinate);// 某个点
        pointArr[idx] = point;
        
        if (_locations.count == 1) {      // 初次进入地图后显示初始中心点，locations每10秒会增加一个经纬度点
            [_trackingMapView setCenterCoordinate:coordinate];
        }
        if (idx == (_locations.count - 1)) {// 显示最后一个轨迹点,并绘制路线
            MKPolyline *routeLine = [MKPolyline polylineWithPoints:pointArr count:_locations.count];
            [_trackingMapView removeOverlays:_trackingMapView.overlays];
            [_trackingMapView addOverlay:routeLine];
            
            if (_pinAnnotation) {
                [_trackingMapView removeAnnotation:_pinAnnotation];
            }
            
            self.pinAnnotation = [[CustomAnnotation alloc] initWithCoordinate:coordinate];
            
            DeviceTrackingState *trackingState = _trackingStates[idx];
            NSString *deviceName = [USER_DEFAULT objectForKey:@"DeviceName"];
            NSString *deviceStatus = @"";
            switch ([trackingState.status integerValue]) {
                case 0:
                    deviceStatus = MyLocal(@"状态:未启用");
                    break;
                case 1:
                    deviceStatus = MyLocal(@"状态:运动");
                    break;
                case 2:
                    deviceStatus = MyLocal(@"状态:静止");
                    break;
                case 3:
                    deviceStatus = MyLocal(@"状态:离线");
                    break;
                case 4:
                    deviceStatus = MyLocal(@"状态:欠费");
                    break;
                default:
                    break;
            }
            
            NSString *accStatus = @"";
            switch ([trackingState.acc integerValue]) {
                case 1:
                    accStatus = MyLocal(@"ACC状态:关");
                    break;
                case 2:
                    accStatus = MyLocal(@"ACC状态:开");
                    break;
                default:
                    break;
            }
            
            NSString *locationTime = [NSString stringWithFormat:MyLocal(@"定位时间:%@"),[trackingState.deviceUtcDate substringFromIndex:5]];
            int standingTime = [trackingState.standingTime intValue];
            NSString *standTime = @"";
            NSString *communicationTime = @"";
            int  dayNum = standingTime/(60*24);
            int  hourNum = standingTime%(60*24)/60;
            int  miniues = standingTime%60;
            
            //做时间的处理
            if (dayNum >0) {
                standTime  = [NSString stringWithFormat:MyLocal(@"%d天%d小时%d分钟"),dayNum,hourNum,miniues];
            }else if (dayNum <= 0){
                if (hourNum<=0) {
                    standTime  = [NSString stringWithFormat:MyLocal(@"%d分钟"),miniues];
                }else if (hourNum > 0){
                    standTime  = [NSString stringWithFormat:MyLocal(@"%d小时%d分钟"),hourNum,miniues];
                }
            }
            
            //静止才显示停留时间
            if (standingTime != 0 && [trackingState.status integerValue]==2){
                communicationTime = [NSString stringWithFormat:MyLocal(@"停留时间:%@"),standTime];
            }
            NSLog(@"%@-----------%@",trackingState.deviceUtcDate,trackingState.lastCommunication);
            NSMutableString *annotationTitle = [NSMutableString stringWithFormat:@"%@\n%@", deviceName, deviceStatus];
            
            NSInteger isShowACC = [USER_DEFAULT integerForKey:@"IsShowAcc"];
            if (isShowACC == 1) {
                [annotationTitle appendFormat:@"\n%@", accStatus];
            }
            if (trackingState.showSpeed) {
                [annotationTitle appendFormat:MyLocal(@"\n速度:%@km/h"), trackingState.speed];
            }
//            if (trackingState.showLocationType) {
                if ([trackingState.dataType isEqualToString:@"1"]) {
                    [annotationTitle appendString:MyLocal(@"\n定位方式:卫星定位")];
                    // 蓝色，灰色
                    if ([trackingState.status intValue] == 1 || [trackingState.status intValue] == 2 ) {
                        _pinAnnotation.carIcon = @"blue";
                    }else{
                        _pinAnnotation.carIcon = @"offline";
                    }
                } else if ([trackingState.dataType isEqualToString:@"2"]) {
                    [annotationTitle appendString:MyLocal(@"\n定位方式:LBS")];
                    // 绿色，灰色
                    if ([trackingState.status intValue] == 1 || [trackingState.status intValue] == 2 ) {
                        _pinAnnotation.carIcon = @"green";
                    }else{
                        _pinAnnotation.carIcon = @"offline";
                    }
                }
//            } else {
//                // 蓝色，灰色
//                if ([trackingState.status intValue] == 1 || [trackingState.status intValue] == 2 ) {
//                    _pinAnnotation.carIcon = @"blue";
//                }else{
//                    _pinAnnotation.carIcon = @"offline";
//                }
//            }
            if (trackingState.showBattery) {
                [annotationTitle appendFormat:MyLocal(@"\n电量:%@"), trackingState.battery];
            }

            [annotationTitle appendFormat:@"\n%@\n%@", locationTime, communicationTime];
            
            _pinAnnotation.title = annotationTitle;
            
//            [self.trackingMapView removeAnnotations:_trackingMapView.annotations];
            [self.trackingMapView addAnnotation:_pinAnnotation];
            if (_showCallout) {
                [self.trackingMapView selectAnnotation:_pinAnnotation animated:YES];
            }
            [self.trackingMapView setCenterCoordinate:_pinAnnotation.coordinate animated:NO];
        }
    }
    
    free(pointArr);
}

- (void)showLocation{
    [_locationManager startUpdatingLocation];
    _changLocationButton.selected = !_changLocationButton.selected;
    _isShowHumanLocation = !_isShowHumanLocation;
    if (_changLocationButton.selected) {
         _isShowHumanLocation = YES;
        _trackingMapView.showsUserLocation = YES;
        [self showHumanLocation];
    } else {
        _isShowHumanLocation = NO;
        _trackingMapView.showsUserLocation = NO;
        [self showAnnotation];
    
    }

}
// 显示当前位置
- (void)showHumanLocation
{
   // _isShowHumanLocation = YES;
  //  _trackingMapView.showsUserLocation = YES;

    [_trackingMapView setCenterCoordinate:_userCoordinate animated:YES];
}

- (void)showAnnotation
{
//    _isShowHumanLocation = NO;
//    _trackingMapView.showsUserLocation = NO;

    [_trackingMapView setCenterCoordinate:_pinAnnotation.coordinate animated:YES];
    NSString *latStr = [NSString stringWithFormat:@"%lf", _pinAnnotation.coordinate.latitude];
    NSString *lngStr = [NSString stringWithFormat:@"%lf", _pinAnnotation.coordinate.longitude];
    [USER_DEFAULT setObject:latStr forKey:@"Latitude"];
    [USER_DEFAULT setObject:lngStr forKey:@"Longitude"];
}

- (void)navgationAction
{
    NSString *latStr = [USER_DEFAULT objectForKey:@"Latitude"];
    NSString *lngStr = [USER_DEFAULT objectForKey:@"Longitude"];
    
    if (!latStr) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:MyLocal(@"设备未定位") delegate:nil cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    CLLocationCoordinate2D end = CLLocationCoordinate2DMake([latStr doubleValue], [lngStr doubleValue]);
    MKMapItem *source = [MKMapItem mapItemForCurrentLocation];
    source.name = MyLocal(@"当前位置");
    MKMapItem *destination = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:end addressDictionary:nil]];
    destination.name = MyLocal(@"车辆位置");
    
    if (BYT_IOS7) {
        NavigationViewController *navController = [[NavigationViewController alloc] init];
        navController.hidesBottomBarWhenPushed = YES;
        navController.source = source;
        navController.destination = destination;
        [self.navigationController pushViewController:navController animated:YES];
    } else {
        [MKMapItem openMapsWithItems:@[source, destination] launchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving, MKLaunchOptionsShowsTrafficKey: @YES}];
    }


}

#pragma mark - WebService Request

// 发送webservice请求设备地址（每10秒会请求一次）
- (void)getDeviceLocation
{
    NSString *deviceID = [USER_DEFAULT objectForKey:@"DeviceID"];
    NSString *timeZone = [USER_DEFAULT objectForKey:@"TimeZone"];
    NSString *mapType = @"Google";
    
    WebService *webService = [WebService newWithWebServiceAction:@"GetTracking" andDelegate:self];
    WebServiceParameter *GetTrackingParameter1 = [WebServiceParameter newWithKey:@"DeviceID" andValue:deviceID];
    WebServiceParameter *GetTrackingParameter2 = [WebServiceParameter newWithKey:@"TimeZone" andValue:timeZone];
    WebServiceParameter *GetTrackingParameter3 = [WebServiceParameter newWithKey:@"MapType" andValue:mapType];
    
    NSArray *parameter = @[GetTrackingParameter1, GetTrackingParameter2, GetTrackingParameter3];
    // webservice请求并获得结果
    webService.webServiceParameter = parameter;
    webService.tag = WebServiceTag_GetTracking;
    [webService getWebServiceResult:@"GetTrackingResult"];
}

- (void)getAddressLatitude:(NSString*)latStr longitude:(NSString *)lngStr
{
    WebService *webService = [WebService newWithWebServiceAction:@"GetAddressByLatlng" andDelegate:self];
    WebServiceParameter *getAddressParameter1 = [WebServiceParameter newWithKey:@"Lat" andValue:latStr];
    WebServiceParameter *getAddressParameter2 = [WebServiceParameter newWithKey:@"Lng" andValue:lngStr];
    WebServiceParameter *getAddressParameter3 = [WebServiceParameter newWithKey:@"MapType" andValue:@"Google"];
    
    NSString *preferredLang = CurrentLanguage;
    if ([preferredLang hasPrefix:@"zh"]) {
        preferredLang = @"ZH-CN";
    } else {
        preferredLang = @"en-us";
    }
    WebServiceParameter *getAddressParameter4 = [WebServiceParameter newWithKey:@"Language" andValue:preferredLang];
    
    NSArray *parameter = @[getAddressParameter1, getAddressParameter2, getAddressParameter3, getAddressParameter4];
    webService.webServiceParameter = parameter;
    webService.tag = WebServiceTag_GetAddress;
    [webService getWebServiceResult:@"GetAddressByLatlngResult"];
}

#pragma mark - WebServiceProtocol

// 每10秒返回一次设备信息（用户名、日期、经纬度、速度）
- (void)WebServiceGetCompleted:(id)theWebService
{
    if (_hud) {
        [_hud hide:YES];
    }
    
    if ([[theWebService soapResults] length] > 0) {
//        SBJsonParser *parser = [[SBJsonParser alloc] init];
//        NSError *error = nil;
        if ([theWebService tag] == WebServiceTag_GetTracking) {
//            id object = [parser objectWithString:[theWebService soapResults] error:&error];
            NSString *str = [theWebService soapResults];
            str = [str stringByReplacingOccurrencesOfString:@"	" withString:@""];
            id object = [str objectFromJSONString];
            if (object) {
                if ([[object objectForKey:@"state"] intValue] == 0) {
                    self.icon = [object objectForKey:@"icon"];
                    
                    DeviceTrackingState *trackingState = [[DeviceTrackingState alloc] init];
                    trackingState.deviceUtcDate = [object objectForKey:@"deviceUtcDate"];
                    trackingState.speed = [object objectForKey:@"speed"];
                    trackingState.acc = [object objectForKey:@"acc"];
                    trackingState.isStop = [object objectForKey:@"isStop"];
                    trackingState.status = [object objectForKey:@"status"];
                    trackingState.lastCommunication = [object objectForKey:@"lastCommunication"];
                    trackingState.battery = object[@"Battery"];
                    trackingState.dataType = object[@"dataType"];
                    trackingState.standingTime = object[@"stopTimeMinute"];
                    trackingState.showLocationType = [[object objectForKey:@"isShowDataType"] integerValue] == 1;
                    trackingState.showSpeed = [object[@"isShowSpeed"] integerValue] == 1;
                    trackingState.showBattery = [object[@"isShowBattery"] integerValue] == 1;
                    [_trackingStates addObject:trackingState];

                    
                    NSString *latStr = [object objectForKey:@"latitude"];
                    NSString *lngStr = [object objectForKey:@"longitude"];
                    [_locations addObject:[NSString stringWithFormat:@"%f,%f",[latStr floatValue], [lngStr floatValue]]];
                    
                    [self getAddressLatitude:latStr longitude:lngStr];// 请求详细信息
                    if (!_isShowHumanLocation) {
                    [self performSelectorOnMainThread:@selector(loadRoute) withObject:nil waitUntilDone:NO];//在主线程中加载路线
                    }
                } else {
                    
                }
            }
        } else if ([theWebService tag] == WebServiceTag_GetAddress) {
            self.address.text =[NSString stringWithFormat:@" %@",[theWebService soapResults]];
            
            if (!_isShowHumanLocation) {
                [self performSelectorOnMainThread:@selector(showAnnotation) withObject:nil waitUntilDone:NO];
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

#pragma mark - MKMapViewDelegate

// 在地图上展示不同的Annotation
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[CustomAnnotation class]]) {
        
        static NSString *identifier = @"CustomAnnotation";
        // annotation的复用机制，和tableViewCell一样
        CustomAnnotitionView *annotationView = (CustomAnnotitionView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {// 不存在则创建
            annotationView = [[CustomAnnotitionView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        } else {// 存在则直接赋值
            annotationView .annotation = annotation;
        }
        annotationView.message = _pinAnnotation.title;
        //annotationView.carIconStr = [NSString stringWithFormat:@"car_%@.png", _icon];
        
        if (_icon.length > 3) {
            
            if ([_pinAnnotation.carIcon isEqualToString:@"green"]) {
                annotationView.carIconStr = [NSString stringWithFormat:@"item_27_green_%@.png", [_icon substringFromIndex:3]];
            } else if ([_pinAnnotation.carIcon isEqualToString:@"blue"]) {
                annotationView.carIconStr = [NSString stringWithFormat:@"item_27_blue_%@.png", [_icon substringFromIndex:3]];
            } else {
                annotationView.carIconStr = [NSString stringWithFormat:@"item_27_offline_%@.png", [_icon substringFromIndex:3]];
            }
        }
//        annotationView.showTrackInfo = _showCallout;
        
        [annotationView.detailButton addTarget:self action:@selector(didSelectAnnotation) forControlEvents:UIControlEventTouchUpInside];
        
        return annotationView;

    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if ([view isKindOfClass:[CustomAnnotitionView class]]) {
        CustomAnnotitionView *annotationView = (CustomAnnotitionView *)view;
        annotationView.showTrackInfo = YES;
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    if ([view isKindOfClass:[CustomAnnotitionView class]]) {
        CustomAnnotitionView *annotationView = (CustomAnnotitionView *)view;
        annotationView.showTrackInfo = NO;
    }
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id)overlay
{
    if([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineView *routeLineView = [[MKPolylineView alloc] initWithPolyline:overlay];
        routeLineView.fillColor = [UIColor greenColor];
        routeLineView.strokeColor = [UIColor greenColor];
        routeLineView.lineWidth = 5;
        
        return routeLineView;
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    self.userCoordinate = userLocation.coordinate;
}


#pragma mark - CalloutAnnotationViewDelegate

- (void)calloutButtonClicked:(NSString *)title
{
    
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
