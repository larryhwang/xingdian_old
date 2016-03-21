//
//  ListenViewController.m
//  TuQiangCarOnLine
//
//  Created by apple on 15/7/29.
//  Copyright (c) 2015年 thinkrace. All rights reserved.
//

#import "ListenViewController.h"
#import "MJRefresh/MJRefresh.h"
#import "ListenTableViewCell.h"
#import "LMHttpPost.h"
#import "amrFileCodec.h"
#import "SVProgressHUD.h"
#import "FaultViewController.h"
#import <AVFoundation/AVFoundation.h>

#define FilePath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingString:@"/VioceFile"]
//#define isVoiceExist [[NSFileManager defaultManager] fileExistsAtPath:FilePath]
//#define CreatFile if (!isVoiceExist) {[[NSFileManager defaultManager] createDirectoryAtPath:FilePath withIntermediateDirectories:YES attributes:nil error:nil];}

@interface ListenViewController ()<UITableViewDataSource,UITableViewDelegate,AVAudioPlayerDelegate>
@property (nonatomic, strong) UITableView       *ListenTableView;
@property (nonatomic, strong) UIView            *downView;
@property (nonatomic, strong) UIView            *downViewNew;
@property (nonatomic, strong) UIButton          *cleanBtn;
@property (nonatomic, strong) AVAudioPlayer     *audioPlayer;
@property (nonatomic, strong) UILabel           *displayLabel;

@property (nonatomic, strong) NSMutableArray    *dataSourceArray;
@property (nonatomic, strong) NSMutableArray    *deletArray;
@property (nonatomic, strong) NSMutableIndexSet *deletIndexSet;
@property (nonatomic, strong) NSString          *IDFile;
@property (nonatomic, strong) NSString          *getResponseStr;

@property (nonatomic, strong) NSTimer           *displayTimer;
@property (nonatomic, strong) NSTimer           *getResponseTimer;
@property (nonatomic, assign) NSInteger         responseCount;
@property (nonatomic, assign) NSInteger         count;
@property (nonatomic, assign) NSInteger         pageNum;
@property (nonatomic, assign) NSInteger         transitNum;


@end

@implementation ListenViewController
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.title       = NSLocalizedString(@"录音", nil);
        _pageNum         = 1;
        _count           = 0;
        _responseCount   = 0;
        _deletArray      = [[NSMutableArray alloc]init];
        _deletIndexSet   = [[NSMutableIndexSet alloc]init];
        _dataSourceArray = [[NSMutableArray alloc]init];
        _pushID          = [[NSString  alloc] init];
    }
    return self;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    IOS7;
    if (BYT_IOS7) {
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:33/255.0f green:103/255.0f blue:184/255.0f alpha:1.0f];
        self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeTextColor:[UIColor whiteColor]};
    }else {
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:33/255.0f green:103/255.0f blue:184/255.0f alpha:1.0f];
    }
    //  CreatFile;
    
    [self getVoiceList];
    [self initWithItemButtons];
    [self initTableView];
    [self initDownView];
    [self InitPlayer];
    [self initWithLabel];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshlist:) name:@"refreshList" object:nil];
    // Do any additional setup after loading the view.
}
#pragma mark -nsnotification
- (void)refreshlist:(NSNotification *)not{
    _pushID = not.userInfo[@"DeviceID"];
    _pageNum = 1;
    [self getVoiceList];
}
#pragma mark -INITViews
- (void)initWithItemButtons
{
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 11, 21)];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"j.png"] forState:UIControlStateNormal];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"j.png"] forState:UIControlStateHighlighted];
    [leftButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    _cleanBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    _cleanBtn.selected = NO;
    [_cleanBtn setTitle:NSLocalizedString(@"编辑", nil) forState:UIControlStateNormal];
    [_cleanBtn addTarget:self action:@selector(cleanClick:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:_cleanBtn];
    
}
- (void)initTableView
{
    
    _ListenTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, VIEW_WIDTH, VIEW_HEIGHT-64-50)];
    //_ListenTableView.backgroundColor = [UIColor yellowColor];
    _ListenTableView.allowsMultipleSelectionDuringEditing = YES;
    _ListenTableView.editing    = NO;
    _ListenTableView.delegate   = self;
    _ListenTableView.dataSource = self;
   // _ListenTableView.header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getVoiceList)];
    //处理上拉下拉刷新
    _ListenTableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        _pageNum ++;
        [self getVoiceList];
    }];
    _ListenTableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        NSLog(@"%ld",(long)_pageNum);
        _transitNum = _pageNum;
        _pageNum = 1;
        [self.ListenTableView.footer setState:MJRefreshStateIdle];
        [self getVoiceList];
        [self RemoveAll];
        
    }];
       [self.view addSubview:_ListenTableView];
   
}
- (void)initDownView
{
    _downView = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_HEIGHT-64-50, VIEW_WIDTH, 50)];
    //_downView.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:_downView];
    
    UIButton  *listenButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 5, VIEW_WIDTH-200, 40)];
    [listenButton setTitle:NSLocalizedString(@"远程聆听", nil) forState:UIControlStateNormal];
    [listenButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    listenButton.layer.cornerRadius  = 6;
    listenButton.layer.borderWidth   = 1;
    listenButton.layer.borderColor   =[UIColor blackColor].CGColor;
   // listenButton.layer.masksToBounds = YES;
    
    [listenButton addTarget:self action:@selector(listenClick:) forControlEvents:UIControlEventTouchUpInside];
    [_downView addSubview:listenButton];
    [self addNewView];
    
}
#pragma mark -NewView

- (void)addNewView
{
    _downViewNew = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_HEIGHT-64-50, VIEW_WIDTH, 50)];
   // _downViewNew.backgroundColor = [UIColor orangeColor];
    _downViewNew.hidden = YES;
    [self.view addSubview:_downViewNew];
    
    UIButton *allSelect = [[UIButton alloc]initWithFrame:CGRectMake(10, 5, 60, 40)];
    allSelect.layer.cornerRadius = 5;
    allSelect.layer.borderWidth  = 1;
    allSelect.layer.borderColor  = [UIColor blackColor].CGColor;
    [allSelect setTitle:NSLocalizedString(@"全 选", nil) forState:UIControlStateNormal];
    [allSelect setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [allSelect addTarget:self action:@selector(selectAllT) forControlEvents:UIControlEventTouchUpInside];
    [_downViewNew addSubview:allSelect];
    
    UIButton *allCancel = [[UIButton alloc]initWithFrame:CGRectMake(80, 5, 80, 40)];
    allCancel.layer.cornerRadius = 5;
    allCancel.layer.borderWidth  = 1;
    allCancel.layer.borderColor  =[UIColor blackColor].CGColor;
    [allCancel setTitle:NSLocalizedString(@"全不选", nil) forState:UIControlStateNormal];
    [allCancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [allCancel addTarget:self action:@selector(cancelAllT) forControlEvents:UIControlEventTouchUpInside];
    [_downViewNew addSubview:allCancel];
    
    UIButton *deletBtn = [[UIButton alloc]initWithFrame:CGRectMake(VIEW_WIDTH-80  , 5, 60, 40)];
    deletBtn.layer.cornerRadius = 5;
    deletBtn.layer.borderWidth  = 1;
    deletBtn.layer.borderColor  =[UIColor blackColor].CGColor;
    [deletBtn setTitle:NSLocalizedString(@"删除", nil) forState:UIControlStateNormal];
    [deletBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [deletBtn addTarget:self action:@selector(DeleteVoiceByID) forControlEvents:UIControlEventTouchUpInside];
    [_downViewNew addSubview:deletBtn];
    
}
#pragma mark -label
- (void)initWithLabel
{
    _displayLabel = [[UILabel alloc]initWithFrame:CGRectMake((VIEW_WIDTH-100)/2, _downView.frame.origin.y-30, 100, 30)];
    _displayLabel.hidden              = YES;
    _displayLabel.layer.cornerRadius  = 5;
    _displayLabel.layer.masksToBounds = YES;
    _displayLabel.backgroundColor     = [UIColor blackColor];
    _displayLabel.textColor           = [UIColor whiteColor];
    _displayLabel.textAlignment       = NSTextAlignmentCenter;
    _displayLabel.font                = [UIFont systemFontOfSize:15];
    [self.view addSubview:_displayLabel];
}
- (void)dismissLabel
{
    _displayLabel.hidden = YES;
}
#pragma mark -Lifecycle
- (void) viewDidAppear:(BOOL)animated{
    [USER_DEFAULT setObject:@"1" forKey:@"isInListenVC"];
}
-(void)viewWillDisappear:(BOOL)animated{
    if ([_audioPlayer isPlaying]) {
        [_audioPlayer stop];
    }
    if (_getResponseTimer){
        [_getResponseTimer invalidate];
        _getResponseTimer = nil;
    }
    [USER_DEFAULT setObject:@"0" forKey:@"isInListenVC"];
    [SVProgressHUD dismiss];
}
#pragma mark -BUTTONClickEvents
- (void)backAction
{
    if (![self.navigationController popViewControllerAnimated:YES]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
   
}
- (void)cleanClick:(UIButton *)Btn
{
    _cleanBtn.selected = !_cleanBtn.selected;
    
     _downView.hidden = _cleanBtn.selected;
    _downViewNew.hidden = !_cleanBtn.selected;
    
    if (!_cleanBtn.selected) {
        [self RemoveAll];
    }
    [_ListenTableView setEditing:_cleanBtn.selected animated:YES];
    
}
#pragma mark -HandleVoiceFileAndPlayVoice
- (void)playVoice:(UITapGestureRecognizer *)tapGestureRecognizer
{
    UIImageView  *mikeImage =(UIImageView *)tapGestureRecognizer.view;
    NSDictionary *dic       = _dataSourceArray[mikeImage.tag];
    NSLog(@"被点击的单元格数据-----%@",dic);
    NSString     *NetUrl    = dic[@"FilePath"];
    //假如被点击的时候还在播放其他的文件  停止处理
    if ([_audioPlayer isPlaying]) {
        [_audioPlayer stop];
    }
    
    _IDFile = [NSString stringWithFormat:@"%@/%@",FilePath,[USER_DEFAULT objectForKey:@"DeviceID"]];
    //判断文件是否存在，如果存在播放本地文件    如果不存在，播放网络数据并下载
    //[self isExistVoiceFileByID];
    
    NSString *finallyFilePath = [NSString stringWithFormat:@"%@/%@.caf",_IDFile,dic[@"IdentityID"]];
    
    BOOL isFinalyFile = [[NSFileManager defaultManager] fileExistsAtPath:finallyFilePath];
    if (isFinalyFile){
        NSURL         *exiestedUrl = [NSURL URLWithString:finallyFilePath];
        AVAudioPlayer *audioP      = [[AVAudioPlayer alloc]initWithContentsOfURL:exiestedUrl error:nil];
        audioP.delegate = self;
        [audioP prepareToPlay];
        [audioP play];
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
                _audioPlayer = audioPY;
                
            });
        });
        
    }
}

- (void)deleteT
{
    [_dataSourceArray removeObjectsAtIndexes:_deletIndexSet];
    NSMutableArray *indexArray = [[NSMutableArray alloc]init];
    for (int i =0; i<_deletArray.count; i++) {
        
        [indexArray addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
   [_ListenTableView deleteRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationFade];
    [_ListenTableView reloadData];
    [_cleanBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    
    
    
    [self RemoveAll];
}
- (void)selectAllT
{
    [self RemoveAll];
    for (int i=0; i<_dataSourceArray.count; i++) {
        [_deletArray addObject:[NSNumber numberWithInt:i]];
        [_deletIndexSet addIndex:i];
        [_ListenTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
}
- (void)cancelAllT
{
    [self RemoveAll];
    for (int i=0; i<_dataSourceArray.count; i++) {
        [_ListenTableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES];
    }
}
#pragma mark -NetWork
- (void)getVoiceList
{
    [SVProgressHUD show];
    NSString *deviceID = [USER_DEFAULT objectForKey:@"DeviceID"];
    if (![self isBlankString:_pushID]) {
        deviceID = _pushID;
    }
    NSDictionary *param = [NSDictionary dictionaryWithObjects:@[deviceID,[NSNumber numberWithInteger:_pageNum],@"10",@"0"] forKeys:@[@"deviceID",@"pageNo",@"pageCount",@"deleted"]];
    LMHttpPost   *post  = [[LMHttpPost alloc]init];
    [post getResponseWithName:@"GetVoiceList" parameters:param success:^(id responseObject) {
        [self EndRefresh];
        [SVProgressHUD dismiss];
        NSDictionary *json = responseObject;
        NSLog(@"GetVoiceListReturn----%@",json);
        if ([json[@"state"] isEqualToString:@"1000"]) {
            if (_pageNum == 1) {
                [_dataSourceArray removeAllObjects];
            }
            if ([json[@"resSize"]integerValue]<10) {
                [_ListenTableView.footer setState:MJRefreshStateNoMoreData];
            }
            [_dataSourceArray addObjectsFromArray:json[@"arr"]];
            
            [_ListenTableView reloadData];
            [self SelectedRowAfterRefresh];
            
        }
    } failure:^(NSError *error) {
        [self EndRefresh];
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"网络错误", nil) duration:2];
        if (_pageNum>1) {
            _pageNum--;
        }
        if (_pageNum == 1) {
            _pageNum = _transitNum;
        }

    }];
}
- (void)DeleteVoiceByID
{
    [SVProgressHUD show];
    NSMutableString *IDStr = [[NSMutableString alloc]init];
    NSMutableArray  *IdentityIdArray= [[NSMutableArray alloc]init];
    if (_deletArray.count == 0 ){
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"请选择删除的选项", nil) duration:2];
        return;
    }
    if (_deletArray.count > 0) {
        for (int i =0 ; i<_deletArray.count; i++) {
            NSNumber  *NUM = _deletArray[i];
            int        num = [NUM intValue];
         NSDictionary *dit = _dataSourceArray[num];
        [IdentityIdArray addObject:dit[@"IdentityID"]];
            
            if (i==0) {
                [IDStr appendString:dit[@"ID"]];
            }else {
                [IDStr appendString:[NSString stringWithFormat:@",%@",dit[@"ID"]]];
            }
        }
    }
    
    NSDictionary *param = [NSDictionary dictionaryWithObjects:@[IDStr] forKeys:@[@"Ids"]];
    LMHttpPost   *post  = [[LMHttpPost alloc]init];
    [post getResponseWithName:@"SetVoicesIsRead" parameters:param success:^(id responseObject) {
        [SVProgressHUD dismiss];
        NSDictionary *json = responseObject;
        if ([json[@"state"] isEqualToString:@"1000"]) {
            //成功
            if (IdentityIdArray.count>0) {
                //删除本地文件
                for (NSString *identity in IdentityIdArray) {
                    NSString *removePath = [NSString stringWithFormat:@"%@/%@.caf",_IDFile,identity];
                    BOOL  isR = [[NSFileManager defaultManager] fileExistsAtPath:removePath];
                    if (isR) {
                        [[NSFileManager defaultManager] removeItemAtPath:removePath error:nil];
                    }
                }
            }
            [self deleteT];
        
        }else if ([json[@"state"] isEqualToString:@"2001"]){
            //失败
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"失败", nil) duration:1.5];
        }
        
    } failure:^(NSError *error) {
         [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"网络错误", nil) duration:2];
    }];
}
- (void)listenClick:(UIButton *)btn
{
//    _displayLabel.hidden = NO;
//    _displayLabel.text  = NSLocalizedString(@"录音指令下发中", nil);
//    [self LabelAdaptive:_displayLabel];
    [SVProgressHUD show];
    NSString *deviceID = [USER_DEFAULT objectForKey:@"DeviceID"];
    if (_pushID.length != 0) {
        deviceID = _pushID;
    }
    NSDictionary *param = [NSDictionary dictionaryWithObjects:@[deviceID,@"26",@"",@"",@""] forKeys:@[@"deviceID",@"Type",@"Param1",@"Param2",@"Param3"]];
    
    LMHttpPost *post    = [[LMHttpPost alloc]init];
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
            _getResponseStr = responseObject;
            if (_getResponseTimer) {
                [self invalidateResponseTimer];
            }
            _responseCount = 0;
          //  [self performSelector:@selector(getResponse1) withObject:nil afterDelay:0.1];
            _getResponseTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(getResponse1) userInfo:nil repeats:YES];
           // _getResponseTimer  = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(getResponse1) userInfo:nil repeats:YES];
        }
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"网络错误", nil) duration:2];
        [self dismissLabel];
    }];
    
    
}

- (void)getResponse1
{
    NSLog(@"-----响应时间%ld",(long)_responseCount);
    if (_responseCount>30) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"设备无响应", nil) duration:2];
        [self invalidateResponseTimer];
        [self dismissLabel];
        return;
    }
    NSDictionary *param  = [NSDictionary dictionaryWithObjects:@[_getResponseStr] forKeys:@[@"CommandID"]];
    LMHttpPost   *post   = [[LMHttpPost alloc] init];
    [post getResponseWithName:@"GetResponse" parameters:param success:^(id responseObject) {
        NSLog(@"ResponseReturn>>>>>>>>%@",responseObject);
        
        if ([responseObject isEqualToString:@"OK!"]) {
//            _displayLabel.text   = NSLocalizedString(@"录音中...", nil);
//            [self LabelAdaptive:_displayLabel];
//            if (_displayTimer) {
//                [_displayTimer invalidate];
//                _displayTimer = nil;
//            }
//            _count = 0;
//            _displayTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(TimerCount) userInfo:nil repeats:YES];
            [self invalidateResponseTimer];
            [SVProgressHUD showSuccessWithStatus:responseObject duration:2.0]
            ;
        }
        
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"网络错误", nil) duration:2];
        [self invalidateResponseTimer];
        [self dismissLabel];
    }];
    _responseCount+=5;
    
    
}
#pragma mark -UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_cleanBtn.selected) {
        NSLog(@"%@",indexPath);
        [_deletIndexSet addIndex:indexPath.row];
        [_deletArray addObject:[NSNumber numberWithInteger:indexPath.row]];
         NSLog(@"*******%ld---------------shuzu%@-----%@set",(long)indexPath.row,_deletArray,_deletIndexSet);
    }else if (!_cleanBtn.selected){
        [_ListenTableView deselectRowAtIndexPath:indexPath animated:YES];
        FaultViewController *faultVC = [[FaultViewController alloc] init];
        faultVC.dataDictionary = _dataSourceArray[indexPath.row];
        [self.navigationController pushViewController:faultVC animated:YES];
    }
   
}
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_cleanBtn.selected) {
        [_deletIndexSet removeIndex:indexPath.row];
        [_deletArray removeObject:[NSNumber numberWithInteger:indexPath.row]];
        NSLog(@"取消选中%ld   ---数组%@  ------%@",(long)indexPath.row,_deletArray,_deletIndexSet);
    }
    
}
#pragma mark -UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSourceArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"LSCell";
    ListenTableViewCell *cell   = [_ListenTableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
       cell = [[ListenTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(playVoice:)];
//    [cell.mikeImageView addGestureRecognizer:tap];
   // cell.mikeImageView.tag = indexPath.row;
    
    NSDictionary *cellData = _dataSourceArray[indexPath.row];
    NSString *dateStr = cellData[@"VoiceTime"];
    NSString *dateL = [self StrToDate:dateStr];
    NSLog(@"%@------",dateL);
    cell.timeLabel.text    = dateL;
    cell.addressLabel.text = cellData[@"Address"];
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}
#pragma mark -自定义不用改动的方法
#pragma mark -MJRefresh
- (void) EndRefresh
{
    if ([_ListenTableView.header isRefreshing]) {
        [_ListenTableView.header endRefreshing];
    }
    if ([_ListenTableView.footer isRefreshing]) {
        [_ListenTableView.footer endRefreshing];
    }
}
#pragma mark -HandleArray
- (void) RemoveAll
{
    [_deletArray removeAllObjects];
    [_deletIndexSet removeAllIndexes];
}
#pragma mark -InitPlayer
- (void) InitPlayer {
    //初始化播放器的时候如下设置
//    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
//    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
//                            sizeof(sessionCategory),
//                            &sessionCategory);
//    
//    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
//    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
//                             sizeof (audioRouteOverride),
//                             &audioRouteOverride);
//    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    //默认情况下扬声器播放
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
}

//没必要需要这么多级的创建暂时不需要
- (void) isExistVoiceFileByID
{
    NSLog(@"%@",FilePath);
    _IDFile = [NSString stringWithFormat:@"%@/%@",FilePath,[USER_DEFAULT objectForKey:@"DeviceID"]];
    BOOL isIDFile = [[NSFileManager defaultManager] fileExistsAtPath:_IDFile];
    
    if (!isIDFile) {
        [[NSFileManager defaultManager] createDirectoryAtPath:_IDFile withIntermediateDirectories:YES attributes:nil error:nil];
    }

}
#pragma mark  -处理刷新后选中状态
- (void)SelectedRowAfterRefresh
{
    if (_deletArray.count == 0) {
        return;
    }
    for (int i = 0; i<_deletArray.count; i++) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"%ld",(long)[_deletArray[i]integerValue]);
            int  s = [_deletArray[i]intValue];
            [_ListenTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:s inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
        });
            }
  
}
#pragma  mark -LabelAdaptive
- (void)LabelAdaptive:(UILabel *)label
{
    if (BYT_IOS7) {
        CGSize size      = CGSizeMake(VIEW_WIDTH, 30);
        CGSize labelSize = [label.text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:15],NSFontAttributeName ,nil] context:nil].size;
        label.frame      = CGRectMake((VIEW_WIDTH-labelSize.width)/2, label.frame.origin.y, labelSize.width+6, 30);
        
    }else {
        [label sizeToFit];
    }
}
- (void)TimerCount{
    _count ++;
    NSLog(@"%ld",(long)_count);
    if (_count >= 5) {
        _displayLabel.text = NSLocalizedString(@"已录音5秒", nil);

    }
    if (_count >= 10) {
        _displayLabel.text = NSLocalizedString(@"已录音10秒", nil);
        
    }
    if (_count >= 15) {
        _displayLabel.text = NSLocalizedString(@"录音完成", nil);
        
    }
    
    if (_count >18) {
        _count = 0;
        [self dismissLabel];
        [_displayTimer invalidate];
        _displayTimer = nil;
    }
        [self LabelAdaptive:_displayLabel];
 
}
- (void)invalidateResponseTimer
{
    [_getResponseTimer invalidate];
    _getResponseTimer = nil;
    _responseCount    = 0;
}
#pragma mark  -NSDateTranslant
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
- (BOOL)isBlankString:(NSString *)string{
    
    if (string == nil) {
        return YES;
    }
    if (string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
