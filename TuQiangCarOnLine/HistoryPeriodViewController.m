//
//  HistoryPeriodViewController.m
//  NewGps2012
//
//  Created by TR on 13-4-11.
//  Copyright (c) 2013年 thinkrace. All rights reserved.
//

#import "HistoryPeriodViewController.h"
#import "HistoryViewController.h"
#import "UIImage+Scale.h"
#import "ModelDatePicker.h"

@interface HistoryPeriodViewController ()

@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;

@property (strong, nonatomic) UITextField *startDateText;
@property (strong, nonatomic) UITextField *endDateText;
@property (strong, nonatomic) NSMutableArray *titles;
@property (assign, nonatomic) NSInteger checkMark;

@end

@implementation HistoryPeriodViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

        self.titles = [[NSMutableArray alloc] initWithArray:@[MyLocal(@"当天"), MyLocal(@"昨天"), MyLocal(@"自定义")]];
        self.checkMark = -1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    IOS7;
        
    self.view.backgroundColor = [UIColor colorWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1.0];
    
    if (BYT_IOS7) {
        self.selectTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, VIEW_WIDTH, VIEW_HEIGHT-44-49-20) style:UITableViewStyleGrouped];
    }else{
        self.selectTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, VIEW_WIDTH, VIEW_HEIGHT-44-49) style:UITableViewStyleGrouped];
    }
    self.selectTable.delegate = self;
    self.selectTable.dataSource = self;
    self.selectTable.backgroundView = nil;
    self.selectTable.backgroundColor = [UIColor colorWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1.0];
    [self.view addSubview:_selectTable];
    
    self.startDateText = [[UITextField alloc] initWithFrame:CGRectMake(100, 5, 180, 34)];
    self.startDateText.borderStyle = UITextBorderStyleRoundedRect;
    self.startDateText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.startDateText.delegate = self;

    self.endDateText = [[UITextField alloc] initWithFrame:CGRectMake(100, 5, 180, 34)];
    self.endDateText.borderStyle = UITextBorderStyleRoundedRect;
    self.endDateText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.endDateText.delegate = self;

    UIButton *queryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    queryButton.frame = CGRectMake(10,34*5+44+60, VIEW_WIDTH-20, 50);
    queryButton.titleLabel.font = [UIFont systemFontOfSize:20.0];
//    [queryButton setBackgroundImage:[[UIImage imageNamed:@"3.png"] scaleToSize:CGSizeMake(290, 50)] forState:UIControlStateNormal];
    queryButton.backgroundColor = mycolor;
    [queryButton setTitle:MyLocal(@"查询") forState:UIControlStateNormal];
    [queryButton addTarget:self action:@selector(query) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:queryButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row > 2) {
        return;
    }
    
    _checkMark = indexPath.row;
    
    if (indexPath.row == 2) {
        [_titles removeAllObjects];
        [_titles addObjectsFromArray:@[MyLocal(@"当天"), MyLocal(@"昨天"), MyLocal(@"自定义"), @"", @""]];
    }
    
    if (indexPath.row < 2) {
        [_titles removeAllObjects];
        [_titles addObjectsFromArray:@[MyLocal(@"当天"), MyLocal(@"昨天"), MyLocal(@"自定义")]];
    }
    
    [_selectTable reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.textLabel.text = _titles[indexPath.row];
    if (indexPath.row < 3) {
        if (indexPath.row == _checkMark) {
            cell.imageView.image = [UIImage imageNamed:@"radioButton-s"];
        } else {
            cell.imageView.image = [UIImage imageNamed:@"radioButton"];
        }
    } else if (indexPath.row == 3) {
        cell.textLabel.text = MyLocal(@"开始时间");
        [cell.contentView addSubview:_startDateText];
    } else if (indexPath.row == 4) {
        cell.textLabel.text = MyLocal(@"结束时间");
        [cell.contentView addSubview:_endDateText];
    }
    
    return cell;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
    if (textField == _startDateText) {
        ModelDatePicker *datePicker = [[ModelDatePicker alloc] initWithTitle:MyLocal(@"开始时间") CompleteButton:^(NSDate *selectedDate){
            if (selectedDate) {
                self.startDate = selectedDate;
                textField.text = [dateFormatter stringFromDate:selectedDate];
            }
        } mode:UIDatePickerModeDateAndTime];
        if (_endDate) {
            datePicker.picker.maximumDate = _endDate;
        } else {
            datePicker.picker.maximumDate = [NSDate date];
        }
        [datePicker show];
    } else if (textField == _endDateText) {
        ModelDatePicker *datePicker = [[ModelDatePicker alloc] initWithTitle:MyLocal(@"结束时间") CompleteButton:^(NSDate *selectedDate){
            if (selectedDate) {
                self.endDate = selectedDate;
                textField.text = [dateFormatter stringFromDate:selectedDate];
            }
        } mode:UIDatePickerModeDateAndTime];
        if (_startDate) {
            datePicker.picker.minimumDate = _startDate;
        }
        datePicker.picker.maximumDate = [NSDate date];
        [datePicker show];
    }
    
    return NO;
}

//开始查询
- (void)query
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    if (_checkMark == 0) {
        NSString *time = [dateFormatter stringFromDate:[NSDate date]];
        NSString *startDate = [NSString stringWithFormat:@"%@ 00:00", time];
        NSString *endDate = [NSString stringWithFormat:@"%@ 23:59", time];
        
        [USER_DEFAULT setObject:startDate forKey:@"StartTime"];
        [USER_DEFAULT setObject:endDate forKey:@"EndTime"];
    } else if (_checkMark == 1) {
        NSDate *yesterday = [NSDate dateWithTimeIntervalSinceNow:-(24*60*60)];
        NSString *time = [dateFormatter stringFromDate:yesterday];
        NSString *startDate = [NSString stringWithFormat:@"%@ 00:00", time];
        NSString *endDate = [NSString stringWithFormat:@"%@ 23:59", time];
        
        [USER_DEFAULT setObject:startDate forKey:@"StartTime"];
        [USER_DEFAULT setObject:endDate forKey:@"EndTime"];
    } else if (_checkMark == 2) {
        if (_startDate == nil || _endDate == nil) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:MyLocal(@"开始时间或结束时间错误") delegate:nil cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:nil, nil];
            [alert show];
            return;
        } else {
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
            NSString *startTime = [dateFormatter stringFromDate:_startDate];
            NSString *endTime = [dateFormatter stringFromDate:_endDate];
            [USER_DEFAULT setObject:startTime forKey:@"StartTime"];
            [USER_DEFAULT setObject:endTime forKey:@"EndTime"];
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:MyLocal(@"请选择查询时间") delegate:nil cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    HistoryViewController *historyPlay = [[HistoryViewController alloc] init];
    [self.navigationController pushViewController:historyPlay animated:YES];
}

@end
