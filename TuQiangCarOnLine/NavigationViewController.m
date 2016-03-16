//
//  NavigationViewController.m
//  几米位置在线
//
//  Created by apple on 14-8-26.
//  Copyright (c) 2014年 thinkrace. All rights reserved.
//

#import "NavigationViewController.h"
#import "POIAnnotation.h"

@interface NavigationViewController ()

@property (strong, nonatomic) MKMapView *mapView;

@end

@implementation NavigationViewController

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
    
    IOS7;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 返回按钮
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 11, 21)];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"j.png"] forState:UIControlStateNormal];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"j.png"] forState:UIControlStateHighlighted];
    [leftButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, VIEW_WIDTH, VIEW_HEIGHT)];
    _mapView.delegate = self;
    [self.view addSubview:_mapView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self findDirectionsFrom:_source to:_destination];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)findDirectionsFrom:(MKMapItem *)source to:(MKMapItem *)destination
{
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.source = source;
    request.destination = destination;
    request.transportType = MKDirectionsTransportTypeAutomobile;
    
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
         if (error) {
             NSLog(@"we get an error %@",error);
         } else {
             [self showDirectionsOnMap:response];
         }
     }];
}

- (void)showDirectionsOnMap:(MKDirectionsResponse *)response
{
    MKPlacemark *start = response.source.placemark;
    MKPlacemark *end = response.destination.placemark;
    
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake((start.coordinate.latitude+end.coordinate.latitude)/2, (start.coordinate.longitude+end.coordinate.longitude)/2);
    CLLocationDegrees latitudeDelta = fabs(start.coordinate.latitude-end.coordinate.latitude);
    CLLocationDegrees longitudeDelta = fabs(start.coordinate.longitude-end.coordinate.longitude);
    CLLocationDegrees delta = MAX(latitudeDelta, longitudeDelta);
    MKCoordinateSpan span = MKCoordinateSpanMake(delta, delta);
    [_mapView setRegion:MKCoordinateRegionMake(center, span) animated:YES];
    
    for (MKRoute *route in response.routes) {
        [self.mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
    }
    
    POIAnnotation *startAnnotation = [[POIAnnotation alloc] initWithCoordinate:start.coordinate];
    startAnnotation.type = POITypeSource;
    POIAnnotation *endAnnotation = [[POIAnnotation alloc] initWithCoordinate:end.coordinate];
    endAnnotation.type = POITypeDestination;
    [_mapView addAnnotation:startAnnotation];
    [_mapView addAnnotation:endAnnotation];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        renderer.lineWidth = 5;
        renderer.strokeColor = [UIColor redColor];
        return renderer;
    }
    
    return nil;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[POIAnnotation class]]) {
        POIAnnotation *poiAnnotation = (POIAnnotation *)annotation;
        static NSString *identifier = @"annotationView";
        MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (!annotationView) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:poiAnnotation reuseIdentifier:identifier];
        }
        if (poiAnnotation.type == POITypeSource) {
            annotationView.image = [UIImage imageNamed:@"start"];
        } else {
            annotationView.image = [UIImage imageNamed:@"end"];
        }
        
        return annotationView;
    }
    return nil;
}

@end
