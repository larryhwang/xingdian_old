//
//  FaultViewController.m
//  TuQiangCarOnLine
//
//  Created by apple on 15/8/5.
//  Copyright (c) 2015年 thinkrace. All rights reserved.
//

#import "FaultViewController.h"
#import "arm/amrFileCodec.h"
#import "FaultAnnotation.h"

#import <MapKit/MapKit.h>
#import <AVFoundation/AVFoundation.h>

#define FilePath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingString:@"/VioceFile"]

@interface FaultViewController ()<AVAudioPlayerDelegate,MKMapViewDelegate>
@property (nonatomic , strong) MKMapView  *mapView;
@property (nonatomic , strong) UIButton   *playBtn;
@property (nonatomic , strong) UISlider   *slider;
@property (nonatomic , strong) NSTimer    *timer;
@property (nonatomic , assign) float      count;

@property (nonatomic , strong) NSString       *IDFile;
@property (nonatomic , strong) AVAudioPlayer  *audioPlayer;
@end

@implementation FaultViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        _dataDictionary = [[NSDictionary alloc]init];
        
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    IOS7;
    self.title = NSLocalizedString(@"录音位置", nil);
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 11, 21)];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"j.png"] forState:UIControlStateNormal];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"j.png"] forState:UIControlStateHighlighted];
    [leftButton addTarget:self action:@selector(backA) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    [self initMapView];
    [self initAddressView];
    [self initDownView];
    NSLog(@"%@",_dataDictionary);
    // Do any additional setup after loading the view.
}
- (void)backA
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidDisappear:(BOOL)animated
{
    if ([_audioPlayer isPlaying]) {
        [_audioPlayer stop];
        _audioPlayer = nil;
    }
}
#pragma mark -initViews
- (void)initMapView{
    _mapView = [[MKMapView alloc]initWithFrame:CGRectMake(0, 0, VIEW_WIDTH ,VIEW_HEIGHT-64)];
    NSLog(@"%f",_mapView.frame.size.height);
    _mapView.delegate = self;
    CGFloat lat = [_dataDictionary[@"Latitude"] floatValue];
    CGFloat lon = [_dataDictionary[@"Longitude"] floatValue];
    MKCoordinateRegion region = MKCoordinateRegionMake(CLLocationCoordinate2DMake( lat , lon), MKCoordinateSpanMake( 0.05, 0.05));
    [_mapView setRegion:region];
    
    FaultAnnotation *annotation = [[FaultAnnotation alloc]init];
    annotation.coordinate = CLLocationCoordinate2DMake(lat, lon);
    annotation.title = [USER_DEFAULT objectForKey:@"DeviceName"];
    annotation.image = [UIImage imageNamed:@"mark"];
    NSString *dateStr = _dataDictionary[@"VoiceTime"];
    NSString *dateSubStr = [self StrToDate:dateStr];
    annotation.subtitle = dateSubStr;
    
    [_mapView addAnnotation:annotation];
    
    [self.mapView selectAnnotation:annotation animated:YES];
    [self.view addSubview:_mapView];
    
}
#pragma mark -initaddressView
- (void)initAddressView
{
    UILabel *addressLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, VIEW_WIDTH, 60)];
    addressLabel.alpha = 0.5;
    addressLabel.backgroundColor = [UIColor whiteColor];
    addressLabel.text = _dataDictionary[@"Address"];
    addressLabel.numberOfLines = 2;
    addressLabel.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:addressLabel];
    
}
- (void)initDownView
{
    UIView *downView = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_HEIGHT-50-64, VIEW_WIDTH, 50)];
    
    downView.backgroundColor = [UIColor whiteColor];
    downView.alpha  = 0.8;
    [self.view addSubview:downView];
    
    _playBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 5, 40, 40)];
    [_playBtn setImage:[UIImage imageNamed:@"playV"] forState:UIControlStateNormal];
    [_playBtn setImage:[UIImage imageNamed:@"pauseV"] forState:UIControlStateSelected];
    [_playBtn addTarget:self action:@selector(playVoice:) forControlEvents:UIControlEventTouchUpInside];
    [downView addSubview:_playBtn];
    
    _slider = [[UISlider alloc]initWithFrame:CGRectMake(64, 15, VIEW_WIDTH-74, 20)];
    _slider.maximumValue = 1;
    _slider.userInteractionEnabled = NO;
    [downView addSubview:_slider];
    
    
    
}
#pragma mark -PlayVoice
- (void)playVoice:(UIButton *)btn
{
    btn.selected = !btn.selected;
    if (_timer&&!btn.selected) {
        [_timer setFireDate:[NSDate distantFuture]];
        [_audioPlayer pause];
        return;
    }else if (_timer&&btn.selected){
        [_audioPlayer play];
        [_timer setFireDate:[NSDate distantPast]];
        return;
    }
    if (!btn.selected) {
        return;
    }
    NSString     *NetUrl = _dataDictionary[@"FilePath"];
    //假如被点击的时候还在播放其他的文件  停止处理
    if ([_audioPlayer isPlaying]) {
        [_audioPlayer stop];
    }
    
    _IDFile = [NSString stringWithFormat:@"%@/%@",FilePath,[USER_DEFAULT objectForKey:@"DeviceID"]];
    //判断文件是否存在，如果存在播放本地文件    如果不存在，播放网络数据并下载
    
    NSString *finallyFilePath = [NSString stringWithFormat:@"%@/%@.caf",_IDFile,_dataDictionary[@"IdentityID"]];
    
    BOOL isFinalyFile = [[NSFileManager defaultManager] fileExistsAtPath:finallyFilePath];
    if (isFinalyFile){
        NSURL         *exiestedUrl = [NSURL URLWithString:finallyFilePath];
        AVAudioPlayer *audioP      = [[AVAudioPlayer alloc]initWithContentsOfURL:exiestedUrl error:nil];
        audioP.delegate = self;
        [audioP prepareToPlay];
        [audioP play];
        if ([audioP isPlaying]) {
            _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(progressValueChange) userInfo:nil repeats:YES];

        }
        _audioPlayer = audioP;
        
    }else if(!isFinalyFile){
        NSURL *url = [NSURL URLWithString:NetUrl];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *playData = [[NSData alloc] initWithContentsOfURL:url];
            NSData *cafData  = DecodeAMRToWAVE(playData);
            //写入文件
            [cafData writeToFile:finallyFilePath atomically:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                AVAudioPlayer *audioPY = [[AVAudioPlayer alloc] initWithData:cafData error:nil];
                audioPY.delegate       = self;
                [audioPY prepareToPlay];
                [audioPY play];
                if ([audioPY isPlaying]) {
                    _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(progressValueChange) userInfo:nil repeats:YES];
                    
                }

                _audioPlayer = audioPY;
                
            });
        });
        
    }
}
#pragma mark -ProgressHandle
- (void)progressValueChange
{
    NSLog(@"%f  ---duration%f",_audioPlayer.currentTime,_audioPlayer.duration);
    [_slider setValue:_audioPlayer.currentTime/_audioPlayer.duration animated:YES];
}
#pragma mark -AudioPlayDelegate
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [_timer invalidate];
    _timer  = nil;
    [_slider setValue:0];
    [_playBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
}
#pragma mark -MapViewDelegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[FaultAnnotation class]]) {
        static NSString *key = @"Annotation";
        MKAnnotationView *annotationView = [_mapView dequeueReusableAnnotationViewWithIdentifier:key];
        if (!annotationView) {
            annotationView = [[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:key];
            annotationView.canShowCallout = YES;
            
        }
        annotationView.annotation = annotation;
      // NSString *carIcon = [USER_DEFAULT objectForKey:@"CarAlarmIcon"];
//        UIImageView *imageView =[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
//        imageView.image = [UIImage imageNamed:carIcon];
//        annotationView.leftCalloutAccessoryView = imageView;
  //      [[UIImageView alloc]initWithImage:[UIImage imageNamed:carIcon]];
        annotationView.image = ((FaultAnnotation *)annotation).image;
        return annotationView;
        
    }else{
        return nil;
    }
    
}
-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{

}
-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    [self.mapView selectAnnotation:view.annotation animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSString *)StrToDate:(NSString *)dateStr
{
    NSDate *date = [[NSDate alloc] init];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    date = [dateFormatter dateFromString:dateStr];
    
    NSString *Str = [[NSString alloc]init];
    
    //[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    
    Str = [dateFormatter stringFromDate:date];
    return  Str;
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
