//
//  WebService.h
//  NewGps2012
//
//  Created by TR on 13-1-28.
//  Copyright (c) 2013年 thinkrace. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	WebServiceConnectFailed,
    WebServiceInitFailed,
	WebServiceTimeOut
} WebServiceFailureType;

@protocol WebServiceProtocol <NSObject>
- (void)WebServiceGetCompleted:(id)theWebService;
- (void)WebServiceGetError:(id)theWebService type:(WebServiceFailureType)failureType;

@end

@interface WebService : NSObject <NSXMLParserDelegate>

@property (assign) NSInteger tag;
@property (strong) id <WebServiceProtocol> delegate;
@property (strong) NSString *webServiceUrl;
@property (strong) NSString *webServiceAction;
@property (strong) NSArray *webServiceParameter;
@property (strong) NSMutableData *webData;
@property (strong) NSMutableString *soapResults;// 调用webservice后返回json数据
@property (strong) NSString *webServiceResult;
@property (strong) NSTimer *timer;

- (id)init;
- (id)initWithWebServiceAction:(NSString *)newWebServiceAction andDelegate:(id)newDelegate;
+ (id)newWithWebServiceAction:(NSString *)newWebServiceAction andDelegate:(id)newDelegate;
- (id)initWithWebServiceUrl:(NSString *)newWebServiceUrl andWebServiceAction:(NSString *)newWebServiceAction andDelegate:(id)newDelegate;
+ (id)newWithWebServiceUrl:(NSString *)newWebServiceUrl andWebServiceAction:(NSString *)newWebServiceAction andDelegate:(id)newDelegate;
- (void)getWebServiceResult:(NSString *)aWebServiceResult;
@end
