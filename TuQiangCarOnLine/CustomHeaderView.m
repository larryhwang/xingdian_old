//
//  CustomHeaderView.m
//  NewGps2012
//
//  Created by TR on 13-2-1.
//  Copyright (c) 2013年 thinkrace. All rights reserved.
//

#import "CustomHeaderView.h"

@implementation CustomHeaderView
@synthesize groupNameLabel;
@synthesize unfoldButton;
@synthesize section;
@synthesize unfolded;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame title:(NSString *)title section:(NSInteger)sectionNumber unfolded:(BOOL)isUnfolded
{
    if (self = [super initWithFrame:frame]) {
		UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(clickUnfoldButton)];
        
        
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"l.png"]];
        
        image.userInteractionEnabled = YES;
		[image addGestureRecognizer:tapGesture];
        [self addSubview:image];
        self.backgroundColor = [UIColor colorWithRed:226/255.0 green:219/255.0 blue:201/255.0 alpha:1.0];
        self.section = sectionNumber;
		self.unfolded = isUnfolded;
        
		CGRect groupNameLabelFrame = self.bounds;
        groupNameLabelFrame.origin.x += 39.0;
        groupNameLabelFrame.size.width -= 39.0;
        CGRectInset(groupNameLabelFrame, 0.0, 0.0);
        self.groupNameLabel = [[UILabel alloc] initWithFrame:groupNameLabelFrame];
        groupNameLabel.text = title;
        groupNameLabel.font = [UIFont boldSystemFontOfSize:19.0];
        groupNameLabel.textColor = [UIColor whiteColor];
        groupNameLabel.backgroundColor = [UIColor clearColor];
        [image addSubview:groupNameLabel];
		
		
		self.unfoldButton = [UIButton buttonWithType:UIButtonTypeCustom];
        unfoldButton.frame = CGRectMake(290, 15, 15.0, 15.0);
		[unfoldButton setBackgroundImage:[UIImage imageNamed:@"k.png"] forState:UIControlStateNormal];
		[unfoldButton setBackgroundImage:[UIImage imageNamed:@"k-1.png"] forState:UIControlStateSelected];
		unfoldButton.userInteractionEnabled = NO;
		unfoldButton.selected = isUnfolded;
        [image addSubview:unfoldButton];
		
		self.backgroundColor = [UIColor clearColor];
	}
    
	return self;
}

- (void)clickUnfoldButton
{
	unfoldButton.selected = !unfoldButton.selected;
    
    if (unfoldButton.selected) {
        if ([delegate respondsToSelector:@selector(sectionHeaderView:sectionOpened:)]) {
			[delegate sectionHeaderView:self sectionOpened:section];
		}
    } else {
        if ([delegate respondsToSelector:@selector(sectionHeaderView:sectionClosed:)]) {
			[delegate sectionHeaderView:self sectionClosed:section];
		}
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
