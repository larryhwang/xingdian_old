//
//  ModalDatePicker.m
//  智能手环
//
//  Created by apple on 14-4-7.
//  Copyright (c) 2014年 thinkrace. All rights reserved.
//

#import "ModelDatePicker.h"

@interface ModelDatePicker ()

@property (strong, nonatomic) UIView *modelView;
@property (strong, nonatomic) UIView *pickerBG;

@property (copy, nonatomic) void (^buttonBlock)(NSDate *);

@end

@implementation ModelDatePicker

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithTitle:(NSString *)title CompleteButton:(void (^)(NSDate *selectedDate))sBlock mode:(UIDatePickerMode)datepickerMode;
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    self = [super initWithFrame:CGRectMake(0, 0, window.frame.size.width, window.frame.size.height)];
    if (self) {
        self.buttonBlock = [sBlock copy];
        
        // 模态窗口
        self.modelView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _modelView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        [self addSubview:_modelView];
        
        self.pickerBG = [[UIView alloc] initWithFrame:CGRectMake(0, window.frame.size.height, self.frame.size.width, 260)];
        _pickerBG.backgroundColor = [UIColor whiteColor];
        [self addSubview:_pickerBG];
        
        // 创建工具栏
        UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:MyLocal(@"确定") style:UIBarButtonItemStyleDone target:self action:@selector(complete)];
        UIBarButtonItem *spaceItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 44)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = title;
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:18.0];
        UIBarButtonItem *centerItem = [[UIBarButtonItem alloc] initWithCustomView:titleLabel];
        UIBarButtonItem *spaceItem2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:MyLocal(@"取消") style:UIBarButtonItemStyleBordered target:self action:@selector(dismiss)];
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 44)];
        toolbar.barStyle = UIBarStyleBlack;
        toolbar.translucent = YES;
        toolbar.items = @[leftButton, spaceItem1, centerItem, spaceItem2, rightButton];
        [_pickerBG addSubview:toolbar];

        // 创建选择器
        self.picker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 44, self.frame.size.width, 216)];
        _picker.datePickerMode = datepickerMode;
        [_pickerBG addSubview:_picker];
    }
    
    return self;
}

#pragma mark - Annimation

- (void)show
{
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    [UIView animateWithDuration:0.2 animations:^(void){
        CGRect frame = _pickerBG.frame;
        frame.origin.y -= 260;
        _pickerBG.frame = frame;
    } completion:^(BOOL finished){
        
    }];
}

- (void)complete
{
    [UIView animateWithDuration:0.2 animations:^(void){
        CGRect frame = _pickerBG.frame;
        frame.origin.y += 260;
        _pickerBG.frame = frame;
    } completion:^(BOOL finished){
        _modelView.alpha = 0;
        [self removeFromSuperview];
    }];
    _buttonBlock(_picker.date);
}

- (void)dismiss
{
    [UIView animateWithDuration:0.2 animations:^(void){
        CGRect frame = _pickerBG.frame;
        frame.origin.y += 260;
        _pickerBG.frame = frame;
    } completion:^(BOOL finished){
        _modelView.alpha = 0;
        [self removeFromSuperview];
    }];
    _buttonBlock(nil);
}

@end
