//
//  GeoFenceViewController.m
//  途强
//
//  Created by TR on 13-7-4.
//  Copyright (c) 2013年 thinkrace. All rights reserved.
//

#import "GeoFenceViewController.h"
#import <MapKit/MapKit.h>
#import "GeoFenceAnnotation.h"
#import "GeoFenceAnnotationView.h"
#import "GeoFenceInfoView.h"
#import "CustomAnnotation.h"
#import "LMHttpPost.h"
#import "SVProgressHUD.h"


#define MinRadius 100
#define MaxRadius 5000

typedef NS_ENUM(NSInteger, IssueType) {
    AddGeoFence = 10,
    EditGeoFence,
    DeleteGeoFence
};

@interface GeoFenceViewController () <MKMapViewDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) UIView *geoFenceView;

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) NSArray *geoFences;
@property (nonatomic) NSUInteger maxGeoFenceCount;
@property (nonatomic, strong) GeoFenceAnnotation *seletcedAnnotation;
@property (nonatomic, strong) GeoFenceAnnotation *addedAnnotation;
@property (nonatomic) NSInteger selectedIndex;
@property (nonatomic) BOOL regionFits;

@property (nonatomic, strong) NSString *deviceID;
@property (nonatomic) CLLocationCoordinate2D currentLocation;

@property (nonatomic, strong) UISlider *slider;
@property (strong, nonatomic) UILabel *radiusLabel;

@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSDate *startGetResponseTime;
@property (strong, nonatomic) UIAlertView *alertView;

@end

@implementation GeoFenceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.deviceID = [USER_DEFAULT objectForKey:@"DeviceID"];
        self.selectedIndex = 1;
        self.regionFits = YES;
        
        NSString *type = [USER_DEFAULT objectForKey:@"Type"];
        if ([type isEqualToString:@"GT300"] || [type isEqualToString:@"TR300"]) {
            self.maxGeoFenceCount = 5;
        } else if ([type isEqualToString:@"GT520"] || [type isEqualToString:@"GT500"]||[type isEqualToString:@"GT500S"]) {
            self.maxGeoFenceCount = 10;
        } else {
            self.maxGeoFenceCount = 1;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    IOS7;
    
    if (BYT_IOS7) {
        self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, VIEW_WIDTH, VIEW_HEIGHT-44-70-49-20)];
    }else{
        self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, VIEW_WIDTH, VIEW_HEIGHT-44-70-49)];
    }
    _mapView.delegate = self;
    [self.view addSubview:_mapView];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    longPress.minimumPressDuration = 0.5;//按0.5秒响应longPress方法
    [_mapView addGestureRecognizer:longPress];
    
    self.geoFenceView = [[UIView alloc] init];
    if (BYT_IOS7) {
        _geoFenceView.frame = CGRectMake(0, VIEW_HEIGHT-70-44-49-20, VIEW_WIDTH, 70);
    }else{
        _geoFenceView.frame = CGRectMake(0, VIEW_HEIGHT-70-44-49, VIEW_WIDTH, 70);
    }
    _geoFenceView.backgroundColor = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
    [self.view addSubview:_geoFenceView];
    
    self.slider = [[UISlider alloc] initWithFrame:CGRectMake(60, 0, 200, 23)];
    _slider.minimumValue = MinRadius;
    _slider.maximumValue = MaxRadius;
    _slider.value = 100;
    _slider.minimumTrackTintColor = [UIColor blueColor];
    _slider.maximumTrackTintColor = [UIColor whiteColor];
    [_slider addTarget:self action:@selector(radiusChanged) forControlEvents:UIControlEventValueChanged];
    [_geoFenceView addSubview:_slider];
    
    self.radiusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 23)];
    _radiusLabel.backgroundColor = [UIColor clearColor];
    _radiusLabel.text = MyLocal(@"100M");
    _radiusLabel.textAlignment = NSTextAlignmentRight;
    _radiusLabel.textColor = [UIColor blueColor];
    [_geoFenceView addSubview:_radiusLabel];
    
    UILabel *maxLabel = [[UILabel alloc] initWithFrame:CGRectMake(260, 0, 60, 23)];
    maxLabel.backgroundColor = [UIColor clearColor];
    maxLabel.text = MyLocal(@"5KM");
    maxLabel.textAlignment = NSTextAlignmentLeft;
    maxLabel.textColor = [UIColor blueColor];
    [_geoFenceView addSubview:maxLabel];
    
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.frame = CGRectMake(5, 30, 100, 30);
    [addButton setBackgroundImage:[UIImage imageNamed:@"14540.png"] forState:UIControlStateNormal];
    [addButton setBackgroundImage:[UIImage imageNamed:@"14540-1.png"] forState:UIControlStateHighlighted];
    [addButton setTitle:MyLocal(@"添加围栏") forState:UIControlStateNormal];
    [addButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [addButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [addButton addTarget:self action:@selector(showSelectedGeoFence) forControlEvents:UIControlEventTouchUpInside];
    [_geoFenceView addSubview:addButton];
    
    UIButton *changeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    changeButton.frame = CGRectMake(110, 30, 100, 30);
    [changeButton setBackgroundImage:[UIImage imageNamed:@"14540.png"] forState:UIControlStateNormal];
    [changeButton setBackgroundImage:[UIImage imageNamed:@"14540-1.png"] forState:UIControlStateHighlighted];
    [changeButton setTitle:MyLocal(@"修改围栏") forState:UIControlStateNormal];
    [changeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [changeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [changeButton addTarget:self action:@selector(change) forControlEvents:UIControlEventTouchUpInside];
    [_geoFenceView addSubview:changeButton];
    
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteButton.frame = CGRectMake(215, 30, 100, 30);
    [deleteButton setBackgroundImage:[UIImage imageNamed:@"14540.png"] forState:UIControlStateNormal];
    [deleteButton setBackgroundImage:[UIImage imageNamed:@"14540-1.png"] forState:UIControlStateHighlighted];
    [deleteButton setTitle:MyLocal(@"删除围栏") forState:UIControlStateNormal];
    [deleteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [deleteButton addTarget:self action:@selector(delete) forControlEvents:UIControlEventTouchUpInside];
    [_geoFenceView addSubview:deleteButton];
    
    [self loadGeoFenceData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Target Action

- (void)longPress:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
//        if (_geoFences.count >= _maxGeoFenceCount) {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:MyLocal(@"围栏个数超额") delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//            [alert show];
//            return;
//        }
//        
        self.seletcedAnnotation = nil;
        _selectedIndex = 0;
        [_slider setValue:100];
        _radiusLabel.text = @"100M";

        CGPoint touchPoint = [gestureRecognizer locationInView:_mapView];
        CLLocationCoordinate2D center = [_mapView convertPoint:touchPoint toCoordinateFromView:_mapView];
        self.addedAnnotation = [[GeoFenceAnnotation alloc] initWithCoordinate:center];
        _addedAnnotation.name = @"";
        _addedAnnotation.index = 0;
        _addedAnnotation.number = 0;
        _addedAnnotation.type = @"All";
        _addedAnnotation.radius = 100;
        _addedAnnotation.selected = YES;
        [_mapView addAnnotation:_addedAnnotation];

        [self showGeoFence];
    }
}

- (void)radiusChanged
{
    int radiusEntire = (roundf(_slider.value/100))*100;
    [_slider setValue:radiusEntire];
    _radiusLabel.text = [NSString stringWithFormat:@"%dM", radiusEntire];
    
    [_mapView removeOverlays:_mapView.overlays];
    for (int i = 0; i < _geoFences.count; i++) {
        NSDictionary *geoFence = _geoFences[i];
        double latitude = [geoFence[@"latitude"] doubleValue];
        double longitude = [geoFence[@"longitude"] doubleValue];
        CLLocationCoordinate2D center = CLLocationCoordinate2DMake(latitude, longitude);
        if (i == _selectedIndex-1) {
            MKCircle *currentCircle = [MKCircle circleWithCenterCoordinate:center radius:_slider.value];
            [_mapView addOverlay:currentCircle];
            
//            MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(center, 5*_slider.value, 5*_slider.value);
//            MKCoordinateRegion adjustedRegion = [_mapView regionThatFits:viewRegion];
//            [_mapView setRegion:adjustedRegion animated:YES];
        } else {
            MKCircle *currentCircle = [MKCircle circleWithCenterCoordinate:center radius:[geoFence[@"radius"] integerValue]];
            [_mapView addOverlay:currentCircle];
        }
    }
    
    if (_addedAnnotation) {
        [_mapView removeAnnotation:_addedAnnotation];
        _addedAnnotation.radius = _slider.value;
        [_mapView addAnnotation:_addedAnnotation];
        
        MKCircle *currentCircle = [MKCircle circleWithCenterCoordinate:_addedAnnotation.coordinate radius:_addedAnnotation.radius];
        [_mapView addOverlay:currentCircle];
        
//        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(_addedAnnotation.coordinate, 5*_addedAnnotation.radius, 5*_addedAnnotation.radius);
//        MKCoordinateRegion adjustedRegion = [_mapView regionThatFits:viewRegion];
//        [_mapView setRegion:adjustedRegion animated:YES];
    }
}

- (void)showSelectedGeoFence
{
    
    GeoFenceInfoView *view = [[GeoFenceInfoView alloc] initWithFrame:CGRectZero];
    if (_seletcedAnnotation) {
        view.nameTextField.text = _seletcedAnnotation.name;
        view.type = _seletcedAnnotation.type;
        [view.leftButton setTitle:MyLocal(@"修改") forState:UIControlStateNormal];
        [view.leftButton addTarget:self action:@selector(modify:) forControlEvents:UIControlEventTouchUpInside];
    } else if (_addedAnnotation) {
        view.nameTextField.text = _addedAnnotation.name;
        view.type = _addedAnnotation.type;
        [view.leftButton setTitle:MyLocal(@"添加") forState:UIControlStateNormal];
        [view.leftButton addTarget:self action:@selector(add:) forControlEvents:UIControlEventTouchUpInside];
    }else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:MyLocal(@"请长按地图选择相关区域") delegate:nil cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    for (UIView *subView in _geoFenceView.subviews) {
        subView.userInteractionEnabled = NO;
    }
    
    [view.rightButton addTarget:self action:@selector(dismissGeoFenceInfoView:) forControlEvents:UIControlEventTouchUpInside];
    view.center = _mapView.center;
    [_mapView addSubview:view];
}

- (void)modify:(UIButton *)sender
{
    GeoFenceInfoView *view = (GeoFenceInfoView *)sender.superview;
    if (view.nameTextField.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:MyLocal(@"名字不能为空") delegate:nil cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    NSString *name = @"SendGeofence";
    NSArray *keys = @[@"GeofenceID",@"DeviceID",@"Lat",@"Lng",@"Radius",@"name",@"MapType"];
//    if (view.isModel) {
//        name = @"SendGeofenceEdit2";
//        keys = @[@"DeviceID", @"GeofenceID", @"FenceName", @"Lat", @"Lng", @"Radius", @"alarmType", @"alarmModel", @"MapType"];
//    }else{
//        name = @"SendGeofenceEdit";
//        keys = @[@"DeviceID", @"GeofenceID", @"FenceName", @"Lat", @"Lng", @"Radius", @"alarmType", @"MapType"];
//    }

    NSString *fenceName = view.nameTextField.text ? view.nameTextField.text : @"";
    NSString *lat = [NSString stringWithFormat:@"%f", _seletcedAnnotation.coordinate.latitude];
    NSString *lng = [NSString stringWithFormat:@"%f", _seletcedAnnotation.coordinate.longitude];
    NSString *radius = [NSString stringWithFormat:@"%d", (int)_slider.value/100];
    NSString *alarmType = [view.type isEqualToString:@"All"] ? @"" : view.type;
    NSString *alarmModel = [view.geotype isEqualToString:@"1"] ? @"1" : @"0";
    NSArray *objects = @[];
//    if (view.isModel) {
//        objects = @[_deviceID, _seletcedAnnotation.geoFenceID, fenceName, lat, lng, radius, alarmType, alarmModel, @"Google"];
//    }else{
//        objects = @[_deviceID, _seletcedAnnotation.geoFenceID, fenceName, lat, lng, radius, alarmType, @"Google"];
//    }
    objects = @[_seletcedAnnotation.geoFenceID,_deviceID,lat,lng,radius,fenceName,@"Google"];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    LMHttpPost *httpPost = [[LMHttpPost alloc] init];
    [httpPost getResponseWithName:name parameters:parameters success:^(id responseObject) {
        if ([responseObject isEqualToString:@"3001"]){
            [SVProgressHUD dismiss];
            [self loadGeoFenceData];
        }else{
             [SVProgressHUD dismissWithError:MyLocal(@"网络错误")];
        }
      
        
    } failure:^(NSError *error) {
        [SVProgressHUD dismissWithError:MyLocal(@"网络错误")];
    }];
//    [httpPost getResponseWithName:name parameters:parameters success:^(NSString *string) {
//        [self handleResponse:string];
//    } failure:^(NSError *error) {
//
//    }];
    
    [view removeFromSuperview];
    for (UIView *subView in _geoFenceView.subviews) {
        subView.userInteractionEnabled = YES;
    }
}

- (void)change
{
    if (!_seletcedAnnotation) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:MyLocal(@"请选中要修改的围栏") delegate:nil cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    [self showSelectedGeoFence];
}

- (void)add:(UIButton *)sender
{
    GeoFenceInfoView *view = (GeoFenceInfoView *)sender.superview;
    if (view.nameTextField.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:MyLocal(@"名字不能为空") delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    if (!_addedAnnotation) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:MyLocal(@"请长按地图添加新的围栏") delegate:nil cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:nil, nil];
                [alert show];
                return;
            }

//    if (_geoFences.count >= _maxGeoFenceCount) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:MyLocal(@"围栏个数超额") delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [alert show];
//        return;
//    }
//    NSString *name = @"";
//    NSArray *keys = @[];
    NSArray *objects= @[];
//    if (view.isModel) {
//        name = @"SendGeofenceNew3";
//        keys = @[@"DeviceID", @"FenceName", @"Lat", @"Lng", @"Radius", @"alarmType", @"alarmModel", @"MapType"];
//    }else{
//        name = @"SendGeofenceNew2";
//        keys = @[@"DeviceID", @"FenceName", @"Lat", @"Lng", @"Radius", @"alarmType", @"MapType"];
//    }


    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
//    NSArray *keys = @[@"DeviceID", @"FenceName", @"Lat", @"Lng", @"Radius", @"alarmType", @"alarmModel", @"MapType"];
    NSString *fenceName = view.nameTextField.text ? view.nameTextField.text : @"";
    NSString *lat = [NSString stringWithFormat:@"%f", _addedAnnotation.coordinate.latitude];
    NSString *lng = [NSString stringWithFormat:@"%f", _addedAnnotation.coordinate.longitude];
    NSString *radius = [NSString stringWithFormat:@"%d", (int)_slider.value/100];
    NSString *alarmType = [view.type isEqualToString:@"All"] ? @"" : view.type;
    NSString *alarmModel = [view.geotype isEqualToString:@"1"] ? @"1" : @"0";
//    NSArray *objects = @[_deviceID, fenceName, lat, lng, radius, alarmType, alarmModel,@"Google"];
     NSLog(@"alarmModel:%@",alarmModel);
    
    NSString *name = @"SendGeofence";
    NSArray *keys = @[@"GeofenceID",@"DeviceID",@"Lat",@"Lng",@"Radius",@"name",@"MapType"];
    objects = @[@"-1",_deviceID,lat,lng,radius,fenceName,@"Google"];

//    if (view.isModel) {
//        objects = @[_deviceID, fenceName, lat, lng, radius, alarmType, alarmModel, @"Google"];
//    }else{
//        objects = @[_deviceID,fenceName, lat, lng, radius, alarmType, @"Google"];
//    }
    
    
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    LMHttpPost *httpPost = [[LMHttpPost alloc] init];
    [httpPost getResponseWithName:name parameters:parameters success:^(id responseObject) {
        if ([responseObject isEqualToString:@"3001"]){
            [self loadGeoFenceData];
            [SVProgressHUD dismiss];
        }else{
             [SVProgressHUD dismissWithError:MyLocal(@"网络错误")];
        }
        
        
    } failure:^(NSError *error) {
        [SVProgressHUD dismissWithError:MyLocal(@"网络错误")];
    }];
    
//    [httpPost getResponseWithName:name parameters:parameters success:^(NSString *string) {
//        [self handleResponse:string];
//    } failure:^(NSError *error) {
//        [SVProgressHUD dismissWithError:MyLocal(@"网络错误")];
//    }];
    
    [view removeFromSuperview];
    for (UIView *subView in _geoFenceView.subviews) {
        subView.userInteractionEnabled = YES;
    }
}

- (void)dismissGeoFenceInfoView:(UIButton *)sender
{
    [sender.superview removeFromSuperview];
    for (UIView *subView in _geoFenceView.subviews) {
        subView.userInteractionEnabled = YES;
    }
}

//- (void)add
//{
//    if (!_addedAnnotation) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:MyLocal(@"请长按地图添加新的围栏") delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [alert show];
//        return;
//    }
//    if (_geoFences.count >= 10) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:MyLocal(@"围栏个数超额") delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [alert show];
//        return;
//    }
//    
//    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
//    NSArray *keys = @[@"DeviceID", @"FenceName", @"Lat", @"Lng", @"Radius", @"alarmType", @"MapType"];
//    NSString *fenceName = _addedAnnotation.name ? _addedAnnotation.name : @"";
//    NSString *lat = [NSString stringWithFormat:@"%f", _addedAnnotation.coordinate.latitude];
//    NSString *lng = [NSString stringWithFormat:@"%f", _addedAnnotation.coordinate.longitude];
//    NSString *radius = [NSString stringWithFormat:@"%d", (int)_slider.value/100];
//    NSString *alarmType = [_addedAnnotation.type isEqualToString:@"All"] ? @"" : _addedAnnotation.type;
//    NSArray *objects = @[_deviceID, fenceName, lat, lng, radius, alarmType, @"Google"];
//    NSDictionary *parameters = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
//    LMHttpPost *httpPost = [[LMHttpPost alloc] init];
//    [httpPost getResponseWithName:@"SendGeofenceNew2" parameters:parameters success:^(NSString *string) {
//        [self handleResponse:string];
//    } failure:^(NSError *error) {
//        [SVProgressHUD dismissWithError:MyLocal(@"网络错误")];
//    }];
//}

- (void)delete
{
    if (!_seletcedAnnotation) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:MyLocal(@"请选中要删除的围栏") delegate:nil cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    NSArray *keys = @[@"DeviceID", @"GeofenceID"];
    NSArray *objects = @[_deviceID, _seletcedAnnotation.geoFenceID];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    LMHttpPost *httpPost = [[LMHttpPost alloc] init];
    [httpPost getResponseWithName:@"DelGeofence" parameters:parameters success:^(id responseObject) {
        
        [SVProgressHUD dismiss];
       
        if ([responseObject isEqualToString:@"3001"]) {
            [SVProgressHUD showSuccessWithStatus:MyLocal(@"成功") duration:1.5];
            [self loadGeoFenceData];
        }else{
            [SVProgressHUD showErrorWithStatus:MyLocal(@"失败") duration:1.5];
        }
        
    } failure:^(NSError *error) {
        [SVProgressHUD dismissWithError:MyLocal(@"网络错误")];
    }];
//    [httpPost getResponseWithName: parameters:parameters success:^(NSString *string) {
//        
//    } failure:^(NSError *error) {
//        [SVProgressHUD dismissWithError:MyLocal(@"网络错误")];
//    }];
}

- (void)handleResponse:(NSString *)responseString
{
    if ([responseString isEqualToString:@"1001"]) {
        [SVProgressHUD dismiss];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:MyLocal(@"失败") message:MyLocal(@"设备不在线") delegate:nil cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:nil, nil];
        [alert show];
    }else if ([responseString isEqualToString:@"1009"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:MyLocal(@"失败") message:MyLocal(@"失败") delegate:nil cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:nil, nil];
        [alert show];
    } else if ([responseString isEqualToString:@"1002"]) {
        [SVProgressHUD dismiss];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:MyLocal(@"失败") message:MyLocal(@"ID无效") delegate:nil cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:nil, nil];
        [alert show];
    } else if ([responseString isEqualToString:@"2001"]) {
        [SVProgressHUD dismiss];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:MyLocal(@"失败") message:MyLocal(@"设备无返回") delegate:nil cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:nil, nil];
        [alert show];
    } else if ([responseString isEqualToString:@"3001"]) {
        [SVProgressHUD dismiss];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:MyLocal(@"成功") message:nil delegate:nil cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:nil, nil];
        [alert show];
        [self loadGeoFenceData];
    } else {
        NSDictionary *info = @{@"ID": responseString};
        [self timerGetCommandResponse:info];
    }
}

#pragma mark - Web

// 定时30秒调用6次GetResponse方法
- (void)timerGetCommandResponse:(NSDictionary *)info
{
    self.startGetResponseTime = [NSDate date];
    
    if (_timer) {
        [_timer invalidate];
        self.timer = nil;
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(getCommandResponse:) userInfo:info repeats:YES];
    [_timer fire];
}

- (void)getCommandResponse:(NSTimer *)timer
{
    NSDate *date = [NSDate date];
    if ([date timeIntervalSinceDate:_startGetResponseTime] > 30.0) {
        if (_timer) {
            [_timer invalidate];
            self.timer = nil;
        }
        [SVProgressHUD showErrorWithStatus:MyLocal(@"设备未响应")];
        
        return;
    }
    
    NSDictionary *info = timer.userInfo;
    NSDictionary *parameters = @{@"CommandID": info[@"ID"]};
    LMHttpPost *httpPost = [[LMHttpPost alloc] init];
    [httpPost getResponseWithName:@"GetResponse" parameters:parameters success:^(NSString *string) {
        if (string.length > 0) {
            if (_timer) {
                [_timer invalidate];
                self.timer = nil;
            }
            [SVProgressHUD dismiss];
            if (!_alertView) {
                self.alertView = [[UIAlertView alloc] initWithTitle:nil message:string delegate:self cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:nil, nil];
                [_alertView show];
            }
            [self loadGeoFenceData];
        }
    } failure:^(NSError *error) {
        if (_timer) {
            [_timer invalidate];
            self.timer = nil;
        }
        [SVProgressHUD showErrorWithStatus:MyLocal(@"网络错误")];
    }];
}

#pragma mark - Unpublic Methods

- (void)loadGeoFenceData
{
    _selectedIndex = 1;
    self.seletcedAnnotation = nil;
    self.addedAnnotation = nil;
    [_slider setValue:100];
    _radiusLabel.text = @"100M";
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjects:@[[USER_DEFAULT objectForKey:@"DeviceID"], @"Google"] forKeys:@[@"DeviceID", @"mapType"]];
    LMHttpPost *httpPost = [[LMHttpPost alloc] init];
    [httpPost getResponseWithName:@"GetGeofenceList" parameters:parameters success:^(id responseObject) {
        
        NSDictionary *json = responseObject;
        if ([json[@"state"] integerValue] == 0) {
            self.geoFences = json[@"arr"];
            [self showGeoFence];
        }
        
    } failure:^(NSError *error) {
        
    }];
}

// 显示电子围栏位置和范围，并且显示当前选中围栏详情
- (void)showGeoFence
{
    [_mapView removeAnnotations:_mapView.annotations];
    [_mapView removeOverlays:_mapView.overlays];
    for (int i = 0; i < _geoFences.count; i++) {
        NSDictionary *geoFence = _geoFences[i];
        double latitude = [geoFence[@"latitude"] doubleValue];
        double longitude = [geoFence[@"longitude"] doubleValue];
        CLLocationCoordinate2D center = CLLocationCoordinate2DMake(latitude, longitude);
        GeoFenceAnnotation *annotation = [[GeoFenceAnnotation alloc] initWithCoordinate:center];
        annotation.name = geoFence[@"name"];
        annotation.number = [geoFence[@"fenceNo"] integerValue];
        annotation.index = i+1;
        annotation.type = geoFence[@"AlarmType"];
        annotation.radius = [geoFence[@"radius"] integerValue];
        annotation.geoFenceID = geoFence[@"id"];
        annotation.geoFenceNo = geoFence[@"fenceNo"];
        if (i == _selectedIndex-1) {
            annotation.selected = YES;
            self.seletcedAnnotation = annotation;
            [_slider setValue:annotation.radius];
            _radiusLabel.text = [NSString stringWithFormat:@"%@M", [NSNumber numberWithInteger:annotation.radius]];
            
            //            MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 5*annotation.radius, 5*annotation.radius);
            //            MKCoordinateRegion adjustedRegion = [_mapView regionThatFits:viewRegion];
            //            [_mapView setRegion:adjustedRegion animated:YES];
        }
        [_mapView addAnnotation:annotation];
        
        MKCircle *currentCircle = [MKCircle circleWithCenterCoordinate:center radius:[geoFence[@"radius"] integerValue]];
        [_mapView addOverlay:currentCircle];
    }
    
    NSString *latStr = [USER_DEFAULT objectForKey:@"Latitude"];
    NSString *lngStr = [USER_DEFAULT objectForKey:@"Longitude"];
    CustomAnnotation *currentLocationAnnotation = [[CustomAnnotation alloc] initWithCoordinate:CLLocationCoordinate2DMake([latStr doubleValue], [lngStr doubleValue])];
    [_mapView addAnnotation:currentLocationAnnotation];
    if (_regionFits) {
        _regionFits = NO;
        [_mapView setRegion:MKCoordinateRegionMake(currentLocationAnnotation.coordinate, MKCoordinateSpanMake(0.05, 0.05))];
    }
    
    if (_addedAnnotation) {
        [_slider setValue:_addedAnnotation.radius];
        _radiusLabel.text = [NSString stringWithFormat:@"%@M", [NSNumber numberWithInteger:_addedAnnotation.radius]];

        [_mapView addAnnotation:_addedAnnotation];
        MKCircle *currentCircle = [MKCircle circleWithCenterCoordinate:_addedAnnotation.coordinate radius:_addedAnnotation.radius];
        [_mapView addOverlay:currentCircle];
        
//        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(_addedAnnotation.coordinate, 5*_addedAnnotation.radius, 5*_addedAnnotation.radius);
//        MKCoordinateRegion adjustedRegion = [_mapView regionThatFits:viewRegion];
//        [_mapView setRegion:adjustedRegion animated:YES];
    }
}

#pragma mark - MKMapViewDelegate
// 在地图上展示不同的Annotation
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[GeoFenceAnnotation class]]) {
        GeoFenceAnnotation *geoFenceAnnotation = (GeoFenceAnnotation *)annotation;
        
        static NSString *identifier = @"GeoFenceAnnotation";
        GeoFenceAnnotationView *annotationView = [[GeoFenceAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        annotationView.name = geoFenceAnnotation.name;
        annotationView.number = geoFenceAnnotation.number;
        annotationView.type = geoFenceAnnotation.type;
        annotationView.radius = geoFenceAnnotation.radius;
        annotationView.showCallout = geoFenceAnnotation.selected;
        return annotationView;
    } else if ([annotation isKindOfClass:[CustomAnnotation class]]) {
        static NSString *identifier = @"CurrentLocationAnnotation";
        MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        annotationView.image = [UIImage imageNamed:@"item_0"];
        return annotationView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if ([view isKindOfClass:[GeoFenceAnnotationView class]]) {
        GeoFenceAnnotationView *annotationView = (GeoFenceAnnotationView *)view;
        GeoFenceAnnotation *annotation = (GeoFenceAnnotation *)annotationView.annotation;
        if (annotationView.annotation == _addedAnnotation) {
            _selectedIndex = 0;
            self.seletcedAnnotation = nil;
        } else {
            _selectedIndex = annotation.index;
            self.addedAnnotation = nil;
        }
        [_slider setValue:(float)annotation.radius];
        _radiusLabel.text = [NSString stringWithFormat:@"%@M", [NSNumber numberWithInteger:annotation.radius]];
        [_mapView setCenterCoordinate:annotation.coordinate];
        [self showGeoFence];
    }
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKCircle class]]) {
        MKCircleView *circleView = [[MKCircleView alloc] initWithOverlay:overlay];
        circleView.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:0.2];// 圆圈填充色
        circleView.strokeColor = [[UIColor purpleColor] colorWithAlphaComponent:0.7];// 圆圈边界线的颜色
        circleView.lineWidth = 2.0;
        
        return circleView;
    }
    
    return nil;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == _alertView) {
        self.alertView = nil;
    }
}


@end
