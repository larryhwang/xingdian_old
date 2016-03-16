//
//  GeoFenceInfoView.m
//  途强汽车在线
//
//  Created by apple on 14-5-22.
//  Copyright (c) 2014年 thinkrace. All rights reserved.
//

#import "GeoFenceInfoView.h"

@interface GeoFenceInfoView () <UITextFieldDelegate>

@property (strong, nonatomic) UIButton *inButton;
@property (strong, nonatomic) UIButton *outButton;
@property (strong, nonatomic) UIButton *allButton;

@property (strong, nonatomic) UIButton *alarmtpyeButton1;
@property (strong, nonatomic) UIButton *alarmtpyeButton2;
@property (strong, nonatomic) UILabel *geoalarmtypelabel;

@end

@implementation GeoFenceInfoView

- (id)initWithFrame:(CGRect)frame
{
    NSString *type = [USER_DEFAULT objectForKey:@"Type"];
    if ([type isEqualToString:@"GT06N"]||[type isEqualToString:@"GT100"]||[type isEqualToString:@"GT200"]||[type isEqualToString:@"GT220"]||[type isEqualToString:@"GT230"]||[type isEqualToString:@"GT250"]||[type isEqualToString:@"GT280"]||[type isEqualToString:@"GT600"]||[type isEqualToString:@"PA100"]||[type isEqualToString:@"PA200"]||[type isEqualToString:@"TR03D"]||[type isEqualToString:@"WK03D"]||[type isEqualToString:@"ET100"]||[type isEqualToString:@"ET130"]||[type isEqualToString:@"ET150"]||[type isEqualToString:@"ET200"]||[type isEqualToString:@"GT500"]||[type isEqualToString:@"GT500S"]||[type isEqualToString:@"GT520"]||[type isEqualToString:@"GT300"]||[type isEqualToString:@"TR300"])
    {
        self = [super initWithFrame:CGRectMake(0, 0, 240, 200)];
        if (self) {
            self.backgroundColor = [UIColor blueColor];
            self.layer.cornerRadius = 2.0;
            self.isModel = YES;
            self.nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 10, 200, 30)];
            _nameTextField.backgroundColor = [UIColor whiteColor];
            _nameTextField.delegate = self;
            _nameTextField.borderStyle = UITextBorderStyleRoundedRect;
            _nameTextField.returnKeyType = UIReturnKeyDone;
            _nameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            _nameTextField.placeholder = MyLocal(@"围栏名");
            [self addSubview:_nameTextField];
            
            self.inButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _inButton.frame = CGRectMake(20, 50, 50, 20);
            [_inButton setImage:[UIImage imageNamed:@"radioButton2"] forState:UIControlStateNormal];
            [_inButton setImage:[UIImage imageNamed:@"radioButton2-s"] forState:UIControlStateSelected];
            [_inButton setTitle:MyLocal(@"进") forState:UIControlStateNormal];
            [_inButton addTarget:self action:@selector(selectIn) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_inButton];
            
            self.outButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _outButton.frame = CGRectMake(90, 50, 50, 20);
            [_outButton setImage:[UIImage imageNamed:@"radioButton2"] forState:UIControlStateNormal];
            [_outButton setImage:[UIImage imageNamed:@"radioButton2-s"] forState:UIControlStateSelected];
            [_outButton setTitle:MyLocal(@"出") forState:UIControlStateNormal];
            [_outButton addTarget:self action:@selector(selectOut) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_outButton];
            
            self.allButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _allButton.frame = CGRectMake(160, 50, 60, 20);
            [_allButton setImage:[UIImage imageNamed:@"radioButton2"] forState:UIControlStateNormal];
            [_allButton setImage:[UIImage imageNamed:@"radioButton2-s"] forState:UIControlStateSelected];
            [_allButton setTitle:MyLocal(@"进出") forState:UIControlStateNormal];
            [_allButton addTarget:self action:@selector(selectAll) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_allButton];
            
            self.geoalarmtypelabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 75, 180, 20)];
            _geoalarmtypelabel.backgroundColor = [UIColor blueColor];
            _geoalarmtypelabel.text = @"围栏报警方式:";
            _geoalarmtypelabel.textColor = [UIColor whiteColor];
            [self addSubview:_geoalarmtypelabel];
            
            self.alarmtpyeButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
            _alarmtpyeButton1.frame = CGRectMake(20, 100, 90, 20);
            [_alarmtpyeButton1 setImage:[UIImage imageNamed:@"radioButton2"] forState:UIControlStateNormal];
            [_alarmtpyeButton1 setImage:[UIImage imageNamed:@"radioButton2-s"] forState:UIControlStateSelected];
            [_alarmtpyeButton1 setTitle:MyLocal(@"平台报警") forState:UIControlStateNormal];
            _alarmtpyeButton1.selected = YES;
            [_alarmtpyeButton1 addTarget:self action:@selector(selectAlarmtypeButton1) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview: _alarmtpyeButton1];
            
            self.alarmtpyeButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
            _alarmtpyeButton2.frame = CGRectMake(20, 130, 173, 20);
            [_alarmtpyeButton2 setImage:[UIImage imageNamed:@"radioButton2"] forState:UIControlStateNormal];
            [_alarmtpyeButton2 setImage:[UIImage imageNamed:@"radioButton2-s"] forState:UIControlStateSelected];
            [_alarmtpyeButton2 setTitle:MyLocal(@"平台报警+短信报警") forState:UIControlStateNormal];
            [_alarmtpyeButton2 addTarget:self action:@selector(selectAlarmtypeButton2) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview: _alarmtpyeButton2];
            
            self.leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _leftButton.frame = CGRectMake(20, 160, 95, 30);
            [_leftButton setBackgroundImage:[UIImage imageNamed:@"14540"] forState:UIControlStateNormal];
            [_leftButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [self addSubview:_leftButton];
            
            self.rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _rightButton.frame = CGRectMake(125, 160, 95, 30);
            [_rightButton setBackgroundImage:[UIImage imageNamed:@"14540"] forState:UIControlStateNormal];
            [_rightButton setTitle:MyLocal(@"取消") forState:UIControlStateNormal];
            [_rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [self addSubview:_rightButton];
        }
        
    }else{
        
    self = [super initWithFrame:CGRectMake(0, 0, 240, 100)];
    if (self) {
        self.backgroundColor = mycolor;
        self.layer.cornerRadius = 2.0;
        self.isModel = NO;
        self.nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 10, 200, 30)];
        _nameTextField.backgroundColor = [UIColor whiteColor];
        _nameTextField.delegate = self;
        _nameTextField.borderStyle = UITextBorderStyleRoundedRect;
        _nameTextField.returnKeyType = UIReturnKeyDone;
        _nameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _nameTextField.placeholder = MyLocal(@"围栏名");
        [self addSubview:_nameTextField];
        
        self.inButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _inButton.frame = CGRectMake(20, 50, 50, 20);
        [_inButton setImage:[UIImage imageNamed:@"radioButton2"] forState:UIControlStateNormal];
        [_inButton setImage:[UIImage imageNamed:@"radioButton2-s"] forState:UIControlStateSelected];
        [_inButton setTitle:MyLocal(@"进") forState:UIControlStateNormal];
        [_inButton addTarget:self action:@selector(selectIn) forControlEvents:UIControlEventTouchUpInside];
       // [self addSubview:_inButton];
        
        self.outButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _outButton.frame = CGRectMake(90, 50, 50, 20);
        [_outButton setImage:[UIImage imageNamed:@"radioButton2"] forState:UIControlStateNormal];
        [_outButton setImage:[UIImage imageNamed:@"radioButton2-s"] forState:UIControlStateSelected];
        [_outButton setTitle:MyLocal(@"出") forState:UIControlStateNormal];
        [_outButton addTarget:self action:@selector(selectOut) forControlEvents:UIControlEventTouchUpInside];
       // [self addSubview:_outButton];
        
        self.allButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _allButton.frame = CGRectMake(160, 50, 60, 20);
        [_allButton setImage:[UIImage imageNamed:@"radioButton2"] forState:UIControlStateNormal];
        [_allButton setImage:[UIImage imageNamed:@"radioButton2-s"] forState:UIControlStateSelected];
        [_allButton setTitle:MyLocal(@"进出") forState:UIControlStateNormal];
        [_allButton addTarget:self action:@selector(selectAll) forControlEvents:UIControlEventTouchUpInside];
        //[self addSubview:_allButton];
        
        self.leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _leftButton.frame = CGRectMake(20, 60, 95, 30);
        [_leftButton setBackgroundImage:[UIImage imageNamed:@"14540"] forState:UIControlStateNormal];
        [_leftButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self addSubview:_leftButton];
        
        self.rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightButton.frame = CGRectMake(125, 60, 95, 30);
        [_rightButton setBackgroundImage:[UIImage imageNamed:@"14540"] forState:UIControlStateNormal];
        [_rightButton setTitle:MyLocal(@"取消") forState:UIControlStateNormal];
        [_rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self addSubview:_rightButton];
    }
 }
    return self;
}

- (void)setType:(NSString *)type
{
    _type = type;
    if ([type isEqualToString:@"IN"]) {
        _inButton.selected = YES;
    } else if ([type isEqualToString:@"OUT"]) {
        _outButton.selected = YES;
    } else if ([type isEqualToString:@"All"]) {
        _allButton.selected = YES;
    }
}

- (void)setgeoType:(NSString *)geotype
{
    _geotype = geotype;
    if ([geotype isEqualToString:@"0"]) {
        _alarmtpyeButton1.selected = YES;
    } else if([geotype isEqualToString:@"1"]){
        _alarmtpyeButton2.selected = YES;
    }
}

- (void)selectIn
{
    _type = @"IN";
    _inButton.selected = YES;
    _outButton.selected = NO;
    _allButton.selected = NO;
}

- (void)selectOut
{
    _type = @"OUT";
    _inButton.selected = NO;
    _outButton.selected = YES;
    _allButton.selected = NO;
}

- (void)selectAll
{
    _type = @"All";
    _inButton.selected = NO;
    _outButton.selected = NO;
    _allButton.selected = YES;
}

- (void)selectAlarmtypeButton1
{
    _geotype = @"0";
    _alarmtpyeButton2.selected = NO;
    _alarmtpyeButton1.selected = YES;

}

- (void)selectAlarmtypeButton2
{
    _geotype = @"1";
    _alarmtpyeButton2.selected = YES;
    _alarmtpyeButton1.selected = NO;
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
  BOOL isContain = [self isContainsEmoji:string];
    if (isContain) {
         return NO;
    }
    return YES;
}
#pragma mark 过滤表情------------华丽的分割线----------
- (BOOL)isContainsEmoji:(NSString *)string {
    __block BOOL isEomji = NO;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         const unichar hs = [substring characterAtIndex:0];
         if (0xd800 <= hs && hs <= 0xdbff) {
             if (substring.length > 1) {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f77f) {
                     isEomji = YES;
                 }
             }
         } else if (substring.length > 1) {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3) {
                 isEomji = YES;
             }
         } else {
             if (0x2100 <= hs && hs <= 0x27ff && hs != 0x263b) {
                 isEomji = YES;
             } else if (0x2B05 <= hs && hs <= 0x2b07) {
                 isEomji = YES;
             } else if (0x2934 <= hs && hs <= 0x2935) {
                 isEomji = YES;
             } else if (0x3297 <= hs && hs <= 0x3299) {
                 isEomji = YES;
             } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50|| hs == 0x231a ) {
                 isEomji = YES;
             }
         }
     }];
    return isEomji;
}
@end
