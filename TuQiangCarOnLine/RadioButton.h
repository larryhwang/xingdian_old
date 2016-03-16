//
//  RadioButton.h
//  NewGps2012
//
//  Created by TR on 13-4-11.
//  Copyright (c) 2013年 thinkrace. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RadioButtonDelegate <NSObject>
- (void)radioButtonSelectedAtIndex:(NSUInteger)index inGroup:(NSString*)groupId;
@end

@interface RadioButton : UIView

@property (strong, nonatomic) NSString *groupId;
@property (assign, nonatomic) NSUInteger index;
@property (strong, nonatomic) UIButton *button;

- (id)initWithGroupId:(NSString*)groupId index:(NSUInteger)index;
+ (void)addObserverForGroupId:(NSString*)groupId observer:(id)observer;

@end
