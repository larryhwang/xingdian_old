//
//  LocationViewController.h
//  途强
//
//  Created by TR on 13-9-27.
//  Copyright (c) 2013年 thinkrace. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebService.h"

typedef enum {
	MovingSetWebService = 401,
    MovingOffWebService,
	MovingQueryWebService,
    MovingResponseWebService
} MovingWebServiceType;

@interface LocationViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, WebServiceProtocol>

@end
