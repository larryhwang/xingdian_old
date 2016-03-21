//
//  HistoryViewController.m
//  NewGps2012
//
//  Created by TR on 13-3-13.
//  Copyright (c) 2013年 thinkrace. All rights reserved.
//

#import "HistoryViewController.h"
#import "WebServiceParameter.h"
#import "SBJson.h"
#import "DeviceHistoryState.h"
#import "CustomAnnotitionView.h"
#import "CustomAnnotationView.h"

#define KLine_Width 5
#define KInterval   .5
#define KSpace @"   "
#define KSpeedPrefix  MyLocal(@"   速度:")
#define KSpeedSuffix  @"KM/H"
#define KSpacePrefix  @"   "
#define KLicencePlatePrefix MyLocal(@"   车牌:")

@interface HistoryViewController (){
    //日期
    UILabel *dateLabel;
//    UISlider *slider;
}
@property (strong, nonatomic) NSString *annoStartTime;
@property (assign, nonatomic) CLLocationCoordinate2D annoCoordinate;
@property (assign, nonatomic) NSInteger isStopStartId;
@property (assign, nonatomic) NSInteger isStopEndId;
@property (strong, nonatomic) CustomAnnotation *currentAnnotation;
@property (strong, nonatomic)  UIButton *changePlayButton;
@end

@implementation HistoryViewController

NSInteger currentIndex = 1;// 显示轨迹点数组中的某个轨迹点


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = MyLocal(@"轨迹回放");
        
        self.historyStates = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    IOS7;
    
    // 返回按钮
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 11, 21)];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"j.png"] forState:UIControlStateNormal];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"j.png"] forState:UIControlStateHighlighted];
    [leftButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    //切换播放和暂停
   _changePlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _changePlayButton.frame = CGRectMake(0, 0, 33,25);
    [_changePlayButton setBackgroundImage:[UIImage imageNamed:@"cv-4.png"] forState:UIControlStateNormal];
    _changePlayButton.tag = 1001;
    [_changePlayButton setBackgroundImage:[UIImage imageNamed:@"cv-1.png"] forState:UIControlStateSelected];
    [_changePlayButton addTarget:self action:@selector(changePlayButton:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_changePlayButton];
    
//    //view2
//    UIView *view2 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
//    view2.backgroundColor = [UIColor colorWithRed:62/255.0f green:62/255.0f blue:62/255.0f alpha:1.0f];
    
    
    
//    [view2 addSubview:changePlayButton];
    
//    //播放
//    self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    self.playButton.frame = CGRectMake(9, 4, 45,36);
//    [self.playButton setBackgroundImage:[UIImage imageNamed:@"cv-1.png"] forState:UIControlStateNormal];
//    [self.playButton addTarget:self action:@selector(playTrack) forControlEvents:UIControlEventTouchUpInside];
//    [view2 addSubview:self.playButton];
//    
//    //暂停
//    self.pauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    self.pauseButton.frame = CGRectMake(210, 4, 45,36);
//    [self.pauseButton setBackgroundImage:[UIImage imageNamed:@"cv-4.png"] forState:UIControlStateNormal];
//    [self.pauseButton addTarget:self action:@selector(pauseTrack) forControlEvents:UIControlEventTouchUpInside];
//    [view2 addSubview:self.pauseButton];
    
//    self.stopButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    self.stopButton.frame = CGRectMake(265, 4, 45,36);
//    [self.stopButton setBackgroundImage:[UIImage imageNamed:@"cv-3.png"] forState:UIControlStateNormal];
//    [self.stopButton addTarget:self action:@selector(stopTrack) forControlEvents:UIControlEventTouchUpInside];
//    [view2 addSubview:self.stopButton];

//    //slideview
//    slider = [[UISlider alloc]initWithFrame:CGRectMake(65, 12, 190, 20)];
//    //禁止拖动
//    [slider setEnabled:NO];
//    slider.minimumValue = 0;
//    slider.maximumValue = 100;
//    slider.value = 0;
//    //设置未滑动位置背景图片
//    slider.minimumTrackTintColor = [UIColor blueColor];
//    slider.maximumTrackTintColor = [UIColor whiteColor];
//
//    [view2 addSubview:slider];
    
//    [self.view addSubview:view2];
    //   self.historyMap = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height-44)];
    if (BYT_IOS7) { 
        self.historyMap = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height-44-20)];
    }else{
        self.historyMap = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height-44)];
//           self.historyMap = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height-44)];
    }
    self.historyMap.delegate = self;
    MKCoordinateRegion region = {{0, 0}, {0.05, 0.05}};
    [self.historyMap setRegion:region animated:NO];
    [self.view addSubview:_historyMap];
    
    //---------
    dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(4,0, VIEW_WIDTH -8, 30)];
    dateLabel.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    dateLabel.font = [UIFont systemFontOfSize:13.0];
    dateLabel.numberOfLines = 0;
    [self.view addSubview:dateLabel];
    
//    UIButton *changeMapTypeButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    changeMapTypeButton.frame = CGRectMake(0, 60, 26, 26);
//    [changeMapTypeButton setBackgroundImage:[UIImage imageNamed:@"f.png"] forState:UIControlStateNormal];
//    [changeMapTypeButton addTarget:self action:@selector(changeMapType) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:changeMapTypeButton];

    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    self.hud.color = [UIColor colorWithWhite:0.5 alpha:0.8];
    [self.view addSubview:_hud];
    [_hud show:YES];
    
    [self getHistory];
}

- (void)viewDidAppear:(BOOL)animated
{
    _isStopStartId = -1;
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UnPublic
// 通过webservice获得历史轨迹点
- (void)getHistory
{    
    NSString *deviceID = [USER_DEFAULT objectForKey:@"DeviceID"];
    NSString *startTime;
    if (currentIndex == 1) {
        startTime = [USER_DEFAULT objectForKey:@"StartTime"];
    } else {
        startTime = _lastDeviceUtcDate;
    }
    NSString *endTime = [USER_DEFAULT objectForKey:@"EndTime"];
    NSString *timeZone = [USER_DEFAULT objectForKey:@"TimeZone"];
    NSString *mapType = @"Google";
    NSString *selectCount = @"200";
    
    WebService *webService = [WebService newWithWebServiceAction:@"GetDevicesHistory" andDelegate:self];
    WebServiceParameter *webServiceParameter1 = [[WebServiceParameter alloc] initWithKey:@"DeviceID" andValue:deviceID];
    WebServiceParameter *webServiceParameter2 = [[WebServiceParameter alloc] initWithKey:@"StartTime" andValue:startTime];
    WebServiceParameter *webServiceParameter3 = [[WebServiceParameter alloc] initWithKey:@"EndTime" andValue:endTime];
    WebServiceParameter *webServiceParameter4 = [[WebServiceParameter alloc] initWithKey:@"TimeZone" andValue:timeZone];
    WebServiceParameter *webServiceParameter5 = [[WebServiceParameter alloc] initWithKey:@"ShowLBS" andValue:@"0"];
    WebServiceParameter *webServiceParameter6 = [[WebServiceParameter alloc] initWithKey:@"MapType" andValue:mapType];
    WebServiceParameter *webServiceParameter7 = [[WebServiceParameter alloc] initWithKey:@"SelectCount" andValue:selectCount];
    NSArray *parameters = @[webServiceParameter1, webServiceParameter2, webServiceParameter3, webServiceParameter4, webServiceParameter5, webServiceParameter6, webServiceParameter7];
    webService.webServiceParameter = parameters;
    [webService getWebServiceResult:@"GetDevicesHistoryResult"];
}



// 向地图上添加位置和路线
- (void)loadRoute
{
    // 当已经画出一半路线点时请求更多路线点
    if (currentIndex == roundf(_historyStates.count/2)) {
        [self getHistory];
    }
//    [self.historyMap removeAnnotations:self.historyMap.annotations];
    // 创建CLLocationCoordinate2D数组用于画图
    CLLocationCoordinate2D *pointArray = malloc(sizeof(CLLocationCoordinate2D) * currentIndex);
    // 每次for循环获得起始点到当前显示点之间的所有轨迹点的经纬度，保存在pointArr中
    for (int i = 0; i < currentIndex; i++) {// 获得起始点和当前显示点之间的一系列轨迹点
        DeviceHistoryState *aHistoryState = _historyStates[i];
        CLLocationDegrees latitude  = [aHistoryState.latitude doubleValue];
        CLLocationDegrees longitude = [aHistoryState.longitude doubleValue];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        pointArray[i] = coordinate;
       
        if (currentIndex == 1) {// 显示第一个点时表示是初次加载
            MKCoordinateRegion region = {coordinate, {0.05, 0.05}};
            [self.historyMap setRegion:region animated:NO];
        }
        
        // 添加位置点
        if (i == currentIndex-1) {
            MKPolyline *currentRouteLine = [MKPolyline polylineWithCoordinates:pointArray count:currentIndex];
            [_historyMap removeOverlays:_historyMap.overlays];
            [_historyMap addOverlay:currentRouteLine];
            
            if ([aHistoryState.isStop isEqualToString:@"1"]) {
                if (_isStopStartId == -1) {
                    _isStopStartId = 1;
                    _annoStartTime = aHistoryState.date;
                    _annoCoordinate = CLLocationCoordinate2DMake([aHistoryState.latitude floatValue], [aHistoryState.longitude floatValue]);
                }
                _isStopEndId = -1;
            }else{
                if (_isStopEndId == -1) {
                    _isStopEndId = 1;
                    NSInteger time = [self returnDate:_annoStartTime endDate:aHistoryState.date];
                    if (time >= 540) {
                        NSInteger h = time / 3600;
                        NSInteger m = time % 3600;
                        m = m / 60;
                        CustomAnnotation *currentAnno = [[CustomAnnotation alloc] initWithCoordinate:_annoCoordinate];
                        currentAnno.annotationID = @"YES";
                        currentAnno.imageName = @"history_stopmark2";
                        currentAnno.message = [NSString stringWithFormat:MyLocal(@"停留时间:%@小时%@分钟\n开始时间%@\n开始时间%@"),[NSNumber numberWithInteger:h],[NSNumber numberWithInteger:m],_annoStartTime,aHistoryState.date];
                        [_historyMap addAnnotation:currentAnno];
                    }
                    _isStopStartId = -1;
                }
            }

            NSString *deviceName = [USER_DEFAULT objectForKey:@"DeviceName"];
            NSString *licencePlate = [USER_DEFAULT objectForKey:@"LicencePlate"];
            if (licencePlate == nil || licencePlate.length == 0) {
                licencePlate = MyLocal(@"暂无");
            }
            deviceName = [KSpace stringByAppendingString:deviceName];
            
            if (_currentAnnotation) {
                [_historyMap removeAnnotation:_currentAnnotation];
            }
            
            self.currentAnnotation = [[CustomAnnotation alloc] initWithCoordinate:coordinate];
            _currentAnnotation.annotationID = @"NO";
//            dateLabel.text = [NSString stringWithFormat:MyLocal(@"%@\n经度:%@ 纬度:%@ 速度:%@ KM/h"),aHistoryState.date,aHistoryState.longitude,aHistoryState.latitude,aHistoryState.speed];

            dateLabel.text = [NSString stringWithFormat:MyLocal(@"%@  速度:%@ KM/h"),aHistoryState.date,aHistoryState.speed];

            _currentAnnotation.imageName = @"mark2.png";
//            [_historyMap removeAnnotations:_historyMap.annotations];
            [_historyMap addAnnotation:_currentAnnotation];
            [_historyMap setCenterCoordinate:_currentAnnotation.coordinate animated:NO];
        }
    }
    free(pointArray);
    // 播放到最后一个轨迹点
    if (currentIndex == _historyStates.count) {
        UIAlertView *playEnd = [[UIAlertView alloc]initWithTitle:nil message:MyLocal(@"播放结束") delegate:nil cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:nil];
        [playEnd show];
        
        currentIndex = 1;
        [self.historyTimer setFireDate:[NSDate distantFuture]];
//        _changePlayButton.selected = NO;
        [_changePlayButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        _playButton.selected = NO;
        _pauseButton.selected = NO;
        _stopButton.selected = NO;
    }
//    slider.value++;
    currentIndex++;// 下次画线时点的数量加1
}

#pragma mark - Targeta

- (void)prepareForLoadRoute
{
    self.historyTimer = [NSTimer scheduledTimerWithTimeInterval:KInterval target:self selector:@selector(loadRoute) userInfo:nil repeats:YES];
}

- (void)back
{
    [_historyTimer invalidate];
    self.historyTimer = nil;
    currentIndex = 1;
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)changePlayButton:(UIButton*)button{
    button.selected = !button.selected;
    if (button.selected) {
        if (_historyTimer) {
            [self.historyTimer setFireDate:[NSDate distantFuture]];
        }
    }else{
        if (_historyStates.count > 0) {
            if (_historyTimer == nil) {
                if (_historyStates.count > 0) {
                    self.historyTimer = [NSTimer scheduledTimerWithTimeInterval:KInterval target:self selector:@selector(loadRoute) userInfo:nil repeats:YES];
                }
            } else {
                [self.historyTimer setFireDate:[NSDate distantPast]];
            }
        }
    }
}

//- (void)playTrack
//{
//    if (_historyStates.count > 0) {
//        if (_historyTimer == nil) {
//            if (_historyStates.count > 0) {
//                self.historyTimer = [NSTimer scheduledTimerWithTimeInterval:KInterval target:self selector:@selector(loadRoute) userInfo:nil repeats:YES];
//            }
//        } else {
//            [self.historyTimer setFireDate:[NSDate distantPast]];
//        }
//    }
//}
//
//- (void)pauseTrack
//{
//    if (_historyTimer) {
//        [self.historyTimer setFireDate:[NSDate distantFuture]];
//    }
//}

- (void)stopTrack
{
    if (_historyTimer) {
//        slider.value = 0;
        currentIndex = 1;
        [self.historyTimer setFireDate:[NSDate distantFuture]];
    }
}

// 改变地图类型
- (void)changeMapType
{
    if (_historyMap.mapType == MKMapTypeStandard) {
        [_historyMap setMapType:MKMapTypeHybrid];
    } else if (_historyMap.mapType == MKMapTypeHybrid) {
        [_historyMap setMapType:MKMapTypeStandard];
    }
}

#pragma mark - WebServiceProtocol

- (void)WebServiceGetCompleted:(id)theWebService
{
    if (_hud) {
        [_hud hide:YES];
    }
    
    if ([[theWebService soapResults] length]> 0) {
//        SBJsonParser *parser = [[SBJsonParser alloc] init];
//        NSError *error = nil;
//        id object = [parser objectWithString:[theWebService soapResults] error:&error];
        NSString *str = [theWebService soapResults];
        str = [str stringByReplacingOccurrencesOfString:@"	" withString:@""];
        id object = [str objectFromJSONString];
        if (object) {
            if ([[object objectForKey:@"state"] intValue] == 0) {
                self.lastDeviceUtcDate = [object objectForKey:@"lastDeviceUtcDate"];
                NSArray *historys = [object objectForKey:@"devices"];
//                slider.maximumValue = historys.count;
                if ([historys count] > 0) {
                    // 添加历史轨迹点
                    for (id aHistory in historys) {
                        DeviceHistoryState *aHistoryState = [[DeviceHistoryState alloc] init];
                        aHistoryState.date = [aHistory objectForKey:@"date"];
                        aHistoryState.latitude = [aHistory objectForKey:@"lat"];
                        aHistoryState.longitude = [aHistory objectForKey:@"lng"];
                        aHistoryState.speed = [aHistory objectForKey:@"s"];
                        aHistoryState.isStop = [aHistory objectForKey:@"stop"];
                        aHistoryState.icon = [aHistory objectForKey:@"i"];
                        [self.historyStates addObject:aHistoryState];
                    }
                    if (_historyTimer == nil && currentIndex == 1) {
                        [self performSelectorOnMainThread:@selector(prepareForLoadRoute) withObject:nil waitUntilDone:NO];
                    }
                } else {
                    UIAlertView *getDateNull = [[UIAlertView alloc] initWithTitle:nil message:MyLocal(@"没有查询结果") delegate:self cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:nil];
                    [getDateNull show];
                }
            } else {
                UIAlertView *getError = [[UIAlertView alloc] initWithTitle:nil message:MyLocal(@"没有查询结果") delegate:self cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:nil];
                [getError show];
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
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    if ([view isKindOfClass:[CustomAnnotationView class]]) {
         CustomAnnotation *anno = (CustomAnnotation *)view.annotation;
        CustomAnnotationView *annotationView = (CustomAnnotationView *)view;
        if ([anno.annotationID isEqualToString:@"YES"]) {
            [annotationView.imageView setHidden:NO];
        }
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view{
    if ([view isKindOfClass:[CustomAnnotationView class]]) {
        CustomAnnotationView *annotationView = (CustomAnnotationView *)view;
        [annotationView.imageView setHidden:YES];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    if ([annotation isKindOfClass:[CustomAnnotation class]]) {
        CustomAnnotation *anno = (CustomAnnotation *)annotation;
        if ([anno.annotationID isEqualToString:@"YES"]) {
            static NSString *identifier1 = @"HistoryAnnotation1";
            CustomAnnotationView *annotationView = (CustomAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier1];
            if (annotationView == nil) {
                annotationView = [[CustomAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier1];
            } else {
                annotationView.annotation = annotation;
            }
            [annotationView.imageView setHidden:YES];
            annotationView.messageLabel.text = anno.message;
//          annotationView.carIconStr = @"mark2.png";
            annotationView.carIconStr = anno.imageName;
            
            return annotationView;
        }else{
            static NSString *identifier = @"HistoryAnnotation";
            CustomAnnotitionView *annotationView = (CustomAnnotitionView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
            if (annotationView == nil) {
                annotationView = [[CustomAnnotitionView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            } else {
                annotationView.annotation = annotation;
            }
            [annotationView.imageView setHidden:YES];
            annotationView.messageLabel.text = anno.message;
            annotationView.carIcon.frame = CGRectMake((annotationView.frame.size.width-23)/2, (annotationView.frame.size.height-35-24-9)/2, 23, 35);
//          annotationView.carIconStr = @"mark2.png";
            annotationView.carIconStr = anno.imageName;
            
            return annotationView;
        }
        
    }
    
    return nil;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
        polylineView.fillColor = [UIColor greenColor];
        polylineView.strokeColor = [UIColor greenColor];
        polylineView.lineWidth = KLine_Width;
        return polylineView;
    }
    return nil;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self back];
}

-(NSInteger)returnDate:(NSString *)startDate endDate:(NSString *)endDate{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *start = [dateFormatter dateFromString:startDate];
    NSDate *end = [dateFormatter dateFromString:endDate];
    
    NSTimeInterval startTimes = [start timeIntervalSince1970];
    NSTimeInterval endTimes = [end timeIntervalSince1970];
    
    return endTimes - startTimes;
}

@end
