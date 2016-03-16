//
//  SOSViewController.h
//  途强
//
//  Created by TR on 13-9-27.
//  Copyright (c) 2013年 thinkrace. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebService.h"

typedef enum {
	SOSAddWebService = 301,
    SOSDeleteWebService,
	SOSQueryWebService,
    SOSResponseWebService
} SOSWebServiceType;

@interface SOSViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, WebServiceProtocol,UITextFieldDelegate,UIGestureRecognizerDelegate>

@end
