//
//  IssuesCell.h
//  TuQiangCarOnLine
//
//  Created by MapleStory on 15/4/1.
//  Copyright (c) 2015年 thinkrace. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IssuesCell : UITableViewCell
@property (strong, nonatomic) NSString *imageName;
@property (strong, nonatomic) NSString *labelName;
-(void)SetViewImageFrame:(CGRect)frame;
-(void)SetViewImageDefaultFrame;
@end
