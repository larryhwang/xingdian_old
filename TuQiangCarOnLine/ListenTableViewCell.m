//
//  ListenTableViewCell.m
//  TuQiangCarOnLine
//
//  Created by apple on 15/7/29.
//  Copyright (c) 2015年 thinkrace. All rights reserved.
//

#import "ListenTableViewCell.h"

@implementation ListenTableViewCell
-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _mikeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 45, 50)];
        _mikeImageView.userInteractionEnabled = YES;
        _mikeImageView.image = [UIImage imageNamed:@"mike"];
        [self.contentView addSubview:_mikeImageView];
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(_mikeImageView.frame.origin.x+_mikeImageView.frame.size.width, 5, 200, 20)];
        _timeLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:_timeLabel];
        
        
        _addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(_timeLabel.frame.origin.x, _timeLabel.frame.origin.y+_timeLabel.frame.size.height, self.frame.size.width-_timeLabel.frame.origin.x-15 , 40)];
        _addressLabel.numberOfLines = 2;
        _addressLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:_addressLabel];
        
    }
    return self;
}
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
