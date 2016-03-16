//
//  AlarmLocationViewController.m
//  途强汽车在线
//
//  Created by apple on 14-6-12.
//  Copyright (c) 2014年 thinkrace. All rights reserved.
//

#import "AlarmLocationViewController.h"
#import <MapKit/MapKit.h>
#import "CustomAnnotation.h"
#import "WebService.h"
#import "WebServiceParameter.h"

@interface AlarmLocationViewController () <MKMapViewDelegate, WebServiceProtocol>

@property (strong, nonatomic) MKMapView *mapView;

@end

@implementation AlarmLocationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = MyLocal(@"报警位置");
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
    
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, VIEW_WIDTH, VIEW_HEIGHT-44-(BYT_IOS7 ? 20 : 0))];
    _mapView.delegate = self;
    MKCoordinateRegion region = {{0, 0}, {0.05, 0.05}};
    [_mapView setRegion:region animated:YES];
    [self.view addSubview:_mapView];
    
    UILabel *addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, VIEW_WIDTH, 40)];
    addressLabel.lineBreakMode = NSLineBreakByCharWrapping;
    addressLabel.numberOfLines = 2;
    addressLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
    addressLabel.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    addressLabel.textColor = [UIColor blackColor];
    addressLabel.font = [UIFont systemFontOfSize:14.0];
    addressLabel.text = _alarmAddress;
    [self.view addSubview:addressLabel];
}
- (void)viewWillDisappear:(BOOL)animated{
    
    [USER_DEFAULT setObject:@"0" forKey:@"isInAlertVC"];

}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self getLatLngByAlarmID:_alarmID];
    [USER_DEFAULT setObject:@"1" forKey:@"isInAlertVC"];
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

- (void)showAnnotationWithLat:(CGFloat)latitude Lng:(CGFloat)longitude
{
    CustomAnnotation *annotation = [[CustomAnnotation alloc] initWithCoordinate:CLLocationCoordinate2DMake(latitude, longitude)];
    [_mapView addAnnotation:annotation];
    [_mapView setCenterCoordinate:annotation.coordinate animated:NO];
}

#pragma mark - NetWork

- (void)getLatLngByAlarmID:(NSString *)alarmID
{
    WebService *webService = [WebService newWithWebServiceAction:@"GetWarnLatLng" andDelegate:self];
    WebServiceParameter *GetTrackingParameter1 = [WebServiceParameter newWithKey:@"ExceptionID" andValue:alarmID];
    WebServiceParameter *GetTrackingParameter2 = [WebServiceParameter newWithKey:@"MapType" andValue:@"Google"];
    NSArray *parameter = @[GetTrackingParameter1, GetTrackingParameter2];
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"GetWarnLatLngResult"];
}

#pragma mark - WebServiceProtocol

- (void)WebServiceGetCompleted:(id)theWebService
{
    if ([[theWebService soapResults] length] > 0) {
        NSArray *latLng = [[theWebService soapResults] componentsSeparatedByString:@","];
        if (latLng.count == 2) {
            CGFloat latitude = [latLng[0] floatValue];
            CGFloat longitude = [latLng[1] floatValue];
            [self showAnnotationWithLat:latitude Lng:longitude];
        }
    }
}

- (void)WebServiceGetError:(id)theWebService type:(WebServiceFailureType)failureType
{
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

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[CustomAnnotation class]]) {
        static NSString *identifier = @"CustomAnnotation";
        MKAnnotationView *pinView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (pinView == nil) {// 不存在则创建
            pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        } else {// 存在则直接赋值
            pinView .annotation = annotation;
        }
        pinView.canShowCallout = NO;
        pinView.image = [UIImage imageNamed:@"mark"];
        return pinView;
    }
    
    return nil;
}

@end
