//
//  HYAlertView.h
//  刘红阳
//
//  Created by LiuHongYang on 14/10/20.
//  Copyright (c) 2014年 thinkrace. All rights reserved.
//  Version 1.0.0

#import <UIKit/UIKit.h>

@protocol HYAlertViewDelegate;

@interface HYAlertView : UIView{
    id<HYAlertViewDelegate>       _delegate;
}

@property(nonatomic, strong)id<HYAlertViewDelegate>   delegate;
@property (strong, nonatomic,readonly) NSString *title;
@property (assign, nonatomic,readonly) CGFloat width;
@property (strong, nonatomic) UIColor *titleColor;
//@property (strong, nonatomic) UIView *contentView;

/**
 * 初始化HYAlertView的宽度和标题
 */
-(id)initWithWidth:(CGFloat)width WithTitle:(NSString *)title;

/**
 * (UIView *)contentView
 */
-(void)Show:(UIView *)contentView;
-(void)DisMiss;

@end

@protocol HYAlertViewDelegate <NSObject>

@optional

/**
 * 点击ok按钮是否要关闭HYAlertView的代理
 */
- (BOOL)didSelectedOKDisMiss:(HYAlertView *)alertView;

/**
 * 点击ok按钮的代理
 */
- (void)didSelectedOK:(HYAlertView *)alertView;

/**
 * 点击cancel按钮的代理
 */
- (void)didSelectedCANCEL:(HYAlertView *)alertView;

@end
