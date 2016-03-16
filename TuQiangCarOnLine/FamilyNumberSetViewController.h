//
//  FamilyNumberSetViewController.h
//  途强汽车在线
//
//  Created by MyThinkRace on 13-12-4.
//  Copyright (c) 2013年 thinkrace. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WebService.h"

typedef enum {
    FamilyNumberSetWebService = 401,
    FamilyNumberDeleteWebService,
	FamilyNumberQueryWebService,
    FamilyNumberResponseWebService
}FamilyNumberWebServiceType;

@interface FamilyNumberSetViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,UITextFieldDelegate,UIGestureRecognizerDelegate, UIAlertViewDelegate>

@end
