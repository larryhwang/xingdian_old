//
//  MyserviceViewController.m
//  途强汽车在线
//
//  Created by apple on 15/3/16.
//  Copyright (c) 2015年 thinkrace. All rights reserved.
//

#import "MyserviceViewController.h"
#import "LMHttpPost.h"
#import "SVProgressHUD.h"

@interface MyserviceViewController ()
@property (nonatomic, strong) UILabel *companyLabel;
@property (nonatomic, strong) UILabel *contactLabel;
@property (nonatomic, strong) UILabel *phoneLabel;
@property (nonatomic, strong) UILabel *addressLabel;

@end

@implementation MyserviceViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = MyLocal(@"我的服务商");
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 返回按钮
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 11, 21)];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"j.png"] forState:UIControlStateNormal];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"j.png"] forState:UIControlStateHighlighted];
    [leftButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 30, 60, 30)];
    label1.text =MyLocal(@"服务商:");
    label1.textColor = [UIColor blackColor];
    label1.font = [UIFont boldSystemFontOfSize:17.0];
    [self.view addSubview:label1];
    
    self.companyLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 30, 150, 30)];
    //_companyLabel.text = BYT_LOCALIZED(@"途强");
    _companyLabel.text = @"";
    _companyLabel.textAlignment = NSTextAlignmentLeft;
    _companyLabel.textColor = [UIColor blackColor];
    _companyLabel.font = [UIFont systemFontOfSize:15.0];
    [self.view addSubview:_companyLabel];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(20, 60, 60, 30)];
    label2.text =MyLocal(@"联系人:");
    label2.textColor = [UIColor blackColor];
    label2.font = [UIFont boldSystemFontOfSize:17.0];
    [self.view addSubview:label2];
    
    self.contactLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 60, 150, 30)];
    _contactLabel.text = @"";
    _contactLabel.textAlignment = NSTextAlignmentLeft;
    _contactLabel.textColor = [UIColor blackColor];
    _contactLabel.font = [UIFont systemFontOfSize:15.0];
    [self.view addSubview:_contactLabel];
    
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(20, 90, 60, 30)];
    label3.text =MyLocal(@"电    话:");
    label3.textColor = [UIColor blackColor];
    label3.font = [UIFont boldSystemFontOfSize:17.0];
    [self.view addSubview:label3];
    
    self.phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 90, 150, 30)];
    _phoneLabel.text = @"";
    _phoneLabel.textAlignment = NSTextAlignmentLeft;
    _phoneLabel.textColor = [UIColor blackColor];
    _phoneLabel.font = [UIFont systemFontOfSize:15.0];
    [self.view addSubview:_phoneLabel];
    
    UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectMake(20, 120, 60, 30)];
    label4.text =MyLocal(@"地    址:");
    label4.textColor = [UIColor blackColor];
    label4.font = [UIFont boldSystemFontOfSize:17.0];
    [self.view addSubview:label4];
    
    self.addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 127, 220, 90)];
//_addressLabel.text = BYT_LOCALIZED(@"深圳市宝安67区留仙一路高新奇科技工业园B栋4楼(康凯斯信息技术有限公司)");
    _addressLabel.backgroundColor = [UIColor clearColor];
    _addressLabel.text = @"";
    _addressLabel.numberOfLines = 0;
    _addressLabel.textColor = [UIColor blackColor];
    _addressLabel.font = [UIFont systemFontOfSize:15.0];
    [self.view addSubview:_addressLabel];
    
    [self GetServiceDetail];


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)GetServiceDetail
{
    [SVProgressHUD show];
    LMHttpPost *httpPost = [[LMHttpPost alloc] init];
//    NSInteger loginType = [USER_DEFAULT integerForKey:@"LoginType"];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjects:@[[USER_DEFAULT objectForKey:@"ReturnID"], [NSString stringWithFormat:@"%ld",(long)[USER_DEFAULT integerForKey:@"LoginType"]]] forKeys:@[@"ID", @"loginType"]];
    [httpPost getResponseWithName:@"GetParentUser" parameters:parameters success:^(NSDictionary *json) {
        
        NSLog(@"json = %@",json);
        if ([json[@"state"] isEqualToString:@"10000"]) {
            [SVProgressHUD dismiss];
            NSString *username = json[@"UserName"] ? json[@"UserName"] : @"";
            NSString *firstname = json[@"FirstName"] ? json[@"FirstName"] : @"";
            NSString *phone = json[@"CellPhone"] ? json[@"CellPhone"] : @"";
            NSString *address = json[@"Address"] ? json[@"Address"] : @"";
            
            _companyLabel.text = username;
            _contactLabel.text = firstname;
            _phoneLabel.text = phone;
            _addressLabel.text = address;
            [_addressLabel sizeToFit];
            
        }else{
            
            [SVProgressHUD dismiss];
            
        }
        
        
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        
    }];
    


}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
