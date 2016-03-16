//
//  IssuesViewController.h
//  途强
//
//  Created by TR on 13-9-27.
//  Copyright (c) 2013年 thinkrace. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebService.h"
#import "RadioButton.h"

typedef enum {
	RestartWebService = 201,
    CutOilWebService,
	RestoreOilWebService,
    CutPowerWebService,
	RestorePowerWebService,
    ParamQueryWebService,
    VibrateSettingWebService,
    ResponseWebService,
    MoneyQueryWebService,  //余额查询
    VibrationSetWebService, //震动报警
    DefenseModeWebService   //设防模式
} IssuedWebServiceType;

@interface IssuesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, WebServiceProtocol,RadioButtonDelegate,UITextFieldDelegate>

@end
