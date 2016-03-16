//
//  IssuesCell.m
//  TuQiangCarOnLine
//
//  Created by MapleStory on 15/4/1.
//  Copyright (c) 2015年 thinkrace. All rights reserved.
//

#import "IssuesCell.h"

@interface IssuesCell ()
@property (strong, nonatomic) UIImageView *viewImage;
@property (strong, nonatomic) UILabel *viewLabel;
@end

@implementation IssuesCell
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.viewImage = [[UIImageView alloc]initWithFrame:CGRectMake(30, 0, 65, 60)];
        [self addSubview:_viewImage];
        
        self.viewLabel = [[UILabel alloc]initWithFrame:CGRectMake(_viewImage.frame.origin.x+_viewImage.frame.size.width+20-35, 15, 200, 30)];
        _viewLabel.backgroundColor = [UIColor clearColor];
        _viewLabel.textAlignment = NSTextAlignmentLeft;
        _viewLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:_viewLabel];
        
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0,60-2, 320, 2)];
        imageView.image = [UIImage imageNamed:@"line.png"];
        [self addSubview:imageView];
    }
    return self;
}

-(void)setImageName:(NSString *)imageName
{
    _imageName = imageName;
    _viewImage.image = [UIImage imageNamed:imageName];
}

-(void)setLabelName:(NSString *)labelName
{
    _labelName = labelName;
    _viewLabel.text = labelName;
}

-(void)SetViewImageFrame:(CGRect)frame
{
    _viewImage.frame = frame;
}
//修改4----17
-(void)SetViewImageDefaultFrame
{
    _viewImage.frame = CGRectMake(0, 0, 65, 60);
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
