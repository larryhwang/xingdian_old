//
//  CustomHeaderView.h
//  NewGps2012
//
//  Created by TR on 13-2-1.
//  Copyright (c) 2013年 thinkrace. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomHeaderViewDelegate;

@interface CustomHeaderView : UIView
{
    UILabel *groupNameLabel;
    UIButton *unfoldButton;
    NSInteger section;
    BOOL unfolded;
    id <CustomHeaderViewDelegate> delegate;
}
@property (nonatomic, strong) UILabel *groupNameLabel;// 显示分组名
@property (nonatomic, strong) UIButton *unfoldButton;// 展开分组按钮
@property (nonatomic) NSInteger section;
@property (nonatomic) BOOL unfolded;
@property (nonatomic, strong) id <CustomHeaderViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame title:(NSString *)title section:(NSInteger)sectionNumber unfolded:(BOOL)isUnfolded;

@end

@protocol CustomHeaderViewDelegate <NSObject>

@optional
-(void)sectionHeaderView:(CustomHeaderView *)sectionHeaderView sectionClosed:(NSInteger)section;

-(void)sectionHeaderView:(CustomHeaderView *)sectionHeaderView sectionOpened:(NSInteger)section;

@end
