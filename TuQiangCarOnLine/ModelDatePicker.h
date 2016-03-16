//
//  ModalDatePicker.h
//  智能手环
//
//  Created by apple on 14-4-7.
//  Copyright (c) 2014年 thinkrace. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ModelDatePicker : UIView

@property (strong, nonatomic) UIDatePicker *picker;

- (id)initWithTitle:(NSString *)title CompleteButton:(void (^)(NSDate *selectedDate))sBlock mode:(UIDatePickerMode)datepickerMode;

- (void)show;

@end
