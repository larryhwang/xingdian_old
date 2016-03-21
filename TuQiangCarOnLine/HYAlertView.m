//
//  HYAlertView.m
//  刘红阳
//
//  Created by LiuHongYang on 14/10/20.
//  Copyright (c) 2014年 thinkrace. All rights reserved.
//  Version 1.0.0

#import "HYAlertView.h"
#import <QuartzCore/QuartzCore.h>

@interface HYAlertView ()
@property (strong, nonatomic) UIButton *button1;
@property (strong, nonatomic) UIButton *button2;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIControl *overlayView;
@property (strong, nonatomic) UILabel *titleLabel;
@end

@implementation HYAlertView

@synthesize delegate = _delegate;

-(id)initWithWidth:(CGFloat)width WithTitle:(NSString *)title{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    CGRect frame = CGRectMake((window.frame.size.width-width)/2, 120, width, 80);
    self = [super initWithFrame:frame];
    if (self) {
        _title = title;
        _width = width;
        self.backgroundColor = [UIColor colorWithRed:230 green:230 blue:230 alpha:1];
       [HYAlertView exChangeOut:self dur:.3];
        
//        self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
//        _imageView.image = ImageNamed(@"HYAlertViewBackGround");
//        _imageView.userInteractionEnabled = YES;
//        [self addSubview:_imageView];
        
        self.overlayView = [[UIControl alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        self.overlayView.backgroundColor = [UIColor blackColor];
        self.overlayView.alpha = 0.5;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(TapView:)];
        [self.overlayView addGestureRecognizer:tap];
    }
    return self;
}

-(void)setTitleColor:(UIColor *)titleColor
{
    _titleColor = titleColor;
    if (titleColor) {
        _titleLabel.textColor = titleColor;
    }
}

//输入框失去第一响应者身份
-(void)TapView:(id)sender
{
    for (id view in self.subviews) {
        [self TextResignFirstResponder:view];
        if ([view isKindOfClass:[UIView class]]) {
            UIView *textView = (UIView *)view;
            for (id subView in textView.subviews) {
                [self TextResignFirstResponder:subView];
                if ([subView isKindOfClass:[UIView class]]) {
                    UIView *text1View = (UIView *)subView;
                    for (id sub1View in text1View.subviews) {
                        [self TextResignFirstResponder:sub1View];
                    }
                }
            }
        }
    }
}

-(void)TextResignFirstResponder:(id)view
{
    if ([view isKindOfClass:[UITextField class]]) {
        UITextField *textfield1 = (UITextField *)view;
        [textfield1 resignFirstResponder];
    }
    if ([view isKindOfClass:[UITextView class]]) {
        UITextView *textview1 = (UITextView *)view;
        [textview1 resignFirstResponder];
    }
}

//设置contentview，重新设置self的frame
-(void)SetContentView:(UIView *)contentView
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [self LoadTitleView];
    CGRect frame = contentView.frame;
    frame.origin.y = _titleLabel.frame.size.height+_titleLabel.frame.origin.y+10;
    contentView.frame = frame;
//    _contentView = contentView;
    CGRect selfisframe = self.frame;
    selfisframe.size.height = frame.size.height+50+frame.origin.y;
    CGFloat y = window.frame.size.height-selfisframe.size.height;
    selfisframe.origin.y = y/2;
    if (self.window.frame.size.height<=480) {
        selfisframe.origin.y = y/2 -20;
    }
    self.frame = selfisframe;
    [self addSubview:contentView];
    [self LoadButton];
    _imageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

//设置title
-(void)LoadTitleView
{
    self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 15, _width, 40)];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.numberOfLines = 0;
    if (_titleColor) {
        _titleLabel.textColor = _titleColor;
    }else{
      _titleLabel.textColor = [UIColor colorWithRed:32.0/255.0 green:145.0/255.0 blue:250.0/255.0 alpha:1];
    }
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.font = [UIFont systemFontOfSize:22];
    _titleLabel.text = _title;
    [_titleLabel sizeToFit];
    [self addSubview:_titleLabel];
    CGRect frame = _titleLabel.frame;
    CGFloat width = frame.size.width;
    frame.origin.x = (_width - width)/2;
    _titleLabel.frame = frame;
}

//设置确定和取消按钮
-(void)LoadButton
{
    self.imageView.layer.borderColor = [UIColor colorWithRed:3 green:109 blue:240 alpha:1].CGColor;
    self.imageView.layer.borderWidth = 3;
    
    self.layer.cornerRadius = 5;
    
    self.button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    self.button1.frame = CGRectMake(0, self.frame.size.height-40, self.frame.size.width/2-0.5, 40);
    _button1.backgroundColor = [UIColor clearColor];
    [self.button1 setTitle:NSLocalizedString(@"确定", nil) forState:UIControlStateNormal];
    [self.button1 setTitleColor:[UIColor colorWithRed:32.0/255.0 green:145.0/255.0 blue:250.0/255.0 alpha:1] forState:UIControlStateNormal];
    [self.button1 setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
//        self.button1.layer.borderWidth = 1;
//        self.button1.layer.borderColor = [UIColor grayColor].CGColor;
    [self addSubview:self.button1];
    [self.button1 addTarget:self action:@selector(DidSelectedOK:) forControlEvents:UIControlEventTouchUpInside];
    
    self.button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    self.button2.frame = CGRectMake(self.frame.size.width/2+0.5, self.frame.size.height-40, self.frame.size.width/2-0.5, 40);
    _button2.backgroundColor = [UIColor clearColor];
    [self.button2 setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
    [self.button2 setTitleColor:[UIColor colorWithRed:32.0/255.0 green:145.0/255.0 blue:250.0/255.0 alpha:1] forState:UIControlStateNormal];
    [self.button2 setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
//        self.button2.layer.borderWidth = 1;
//        self.button2.layer.borderColor = [UIColor grayColor].CGColor;
    [self addSubview:self.button2];
    [self.button2 addTarget:self action:@selector(DidSelectedCANCEL:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *line1 = [[UIView alloc]initWithFrame:CGRectMake(0, self.button1.frame.origin.y-1, self.frame.size.width, 1)];
    line1.backgroundColor = [UIColor grayColor];
    [self addSubview:line1];
    
    UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(self.button1.frame.size.width, self.button1.frame.origin.y, 1, self.button1.frame.size.height)];
    line2.backgroundColor = [UIColor grayColor];
    [self addSubview:line2];
}

-(void)Show:(UIView *)contentView
{
    [self SetContentView:contentView];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.overlayView];
    [window addSubview:self];
}

-(void)DisMiss {
    [self.overlayView removeFromSuperview];
    [self removeFromSuperview];
}

-(void)DidSelectedOK:(UIButton *)button
{
    BOOL bo = YES;
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectedOK:)]) {
        [_delegate didSelectedOK:self];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectedOKDisMiss:)]) {
        bo = [_delegate didSelectedOKDisMiss:self];
    }
    if (bo) {
        [self DisMiss];
    }
}

-(void)DidSelectedCANCEL:(UIButton *)button
{
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectedCANCEL:)]) {
        [_delegate didSelectedCANCEL:self];
    }
    [self DisMiss];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
}
*/

+(void)exChangeOut:(UIView *)changeOutView dur:(CFTimeInterval)dur{
    CAKeyframeAnimation * animation;
    animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = dur;
    //animation.delegate = self;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 0.9)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    animation.values = values;
    animation.timingFunction = [CAMediaTimingFunction functionWithName: @"easeInEaseOut"];
    [changeOutView.layer addAnimation:animation forKey:nil];
}

@end
