//
//  AboutViewController.m
//  NewGps2012
//
//  Created by TR on 13-4-16.
//  Copyright (c) 2013年 thinkrace. All rights reserved.
//

#import "AboutViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface AboutViewController ()

@end

@implementation AboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = MyLocal(@"关于本软件");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    IOS7;
    
    self.view.backgroundColor = [UIColor colorWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1.0];
    
    // 返回按钮
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 11, 21)];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"j.png"] forState:UIControlStateNormal];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"j.png"] forState:UIControlStateHighlighted];
    [leftButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
//    NSString *name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
//    NSString *build = [infoDictionary objectForKey:@"CFBundleVersion"];
    
//    NSLog(@"%@,%@", name, build);
    
    UITextView *textView;
    if (BYT_IOS7) {
        textView = [[UITextView alloc]initWithFrame:CGRectMake(10, 20,300 , self.view.frame.size.height - 44 -40 -20)];
    }else{
        textView = [[UITextView alloc]initWithFrame:CGRectMake(10, 20,300 , self.view.frame.size.height - 44 -40)];
    }
    textView.layer.cornerRadius = 14.0;
    textView.layer.borderWidth = 1.5;
    textView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    textView.editable = NO;
    textView.scrollEnabled = NO;
    NSString *content = [NSString stringWithFormat:MyLocal(@"版本号 %@\n本版本适用于ios6.0及以上系统，软件的下载和使用过程中会产生GPRS流量费，该费用由运营商收取。"), version];
    textView.text = MyLocal(content);
    textView.font = [UIFont systemFontOfSize:15.0];
    [self.view addSubview:textView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Target Action

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
