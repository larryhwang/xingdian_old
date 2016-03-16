//
//  WebService.m
//  NewGps2012
//
//  Created by TR on 13-1-28.
//  Copyright (c) 2013年 thinkrace. All rights reserved.
//

#import "WebService.h"
#import "WebServiceParameter.h"

#define TimeOut 20
#define ConnectionInitFailed @"Connection is NULL"
#define ConnectionFailed     @"Connection Error"
#define ConnectionTimeOut    @"Time Out"
//static NSString *const APIBaseURLString = @"http://116.204.15.53/api/OpenAPIV3.asmx";
//static NSString *const APIBaseURLString = @"http://113.98.255.53:9099/api/OpenAPIV3.asmx";
static NSString *const APIBaseURLString = @"http://www.xd-gnss.com/api/openapiv3.asmx";
@implementation WebService

#pragma mark - initialization

- (id)init
{
    return [self initWithWebServiceAction:nil andDelegate:nil];
}

- (id)initWithWebServiceAction:(NSString *)newWebServiceAction andDelegate:(id)newDelegate
{
    return [self initWithWebServiceUrl:APIBaseURLString andWebServiceAction:newWebServiceAction andDelegate:newDelegate];
}

+ (id)newWithWebServiceAction:(NSString *)newWebServiceAction andDelegate:(id)newDelegate
{
    return [self newWithWebServiceUrl:APIBaseURLString andWebServiceAction:newWebServiceAction andDelegate:newDelegate];
}

- (id)initWithWebServiceUrl:(NSString *)newWebServiceUrl
        andWebServiceAction:(NSString *)newWebServiceAction
                andDelegate:(id)newDelegate
{
    if (self = [super init]) {
        self.delegate = newDelegate;
        self.webServiceUrl = newWebServiceUrl;
        self.webServiceAction = newWebServiceAction;
        self.webData = [[NSMutableData alloc] init];
    }
    
    return self;    
}

+ (id)newWithWebServiceUrl:(NSString *)newWebServiceUrl
       andWebServiceAction:(NSString *)newWebServiceAction
               andDelegate:(id)newDelegate
{
    return [[WebService alloc] initWithWebServiceUrl:newWebServiceUrl
                                 andWebServiceAction:newWebServiceAction
                                         andDelegate:newDelegate];
}

#pragma mark - WebService

- (void)getWebServiceResult:(NSString *)aWebServiceResult
{
    if (_timer) {
       [self.timer invalidate]; 
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:TimeOut
                                                  target:self
                                                selector:@selector(timeOut)  
                                                userInfo:nil
                                                 repeats:NO];
    self.webServiceResult = aWebServiceResult;
    NSMutableString *soapMessage =[[NSMutableString alloc] initWithFormat:
                                   @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                                   "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                                   "<soap:Body>\n"
                                   "<%@ xmlns=\"http://tempuri.org/\">",_webServiceAction];
    for (int i = 0; i < _webServiceParameter.count; i++) {
        WebServiceParameter *parmeter = _webServiceParameter[i];
        [soapMessage appendFormat:@"<%@>%@</%@>", parmeter.key, parmeter.value,parmeter.key];
    }          
    [soapMessage appendFormat:@"</%@>"
                                "</soap:Body>\n"
                                "</soap:Envelope>\n", _webServiceAction];
	NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)soapMessage.length];
	
    NSURL *url = [NSURL URLWithString:_webServiceUrl];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    //[urlRequest setTimeoutInterval:TimeOut];
    [urlRequest addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [urlRequest addValue:[NSString stringWithFormat:@"http://tempuri.org/%@", _webServiceAction] forHTTPHeaderField:@"SOAPAction"];
    [urlRequest addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody: [soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
	NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self startImmediately:NO];
    [theConnection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
	if (!theConnection) {
		[self WebServiceGetError:ConnectionInitFailed];
        return;
	}
    [theConnection start];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	[self.webData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[self.webData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    connection = nil;
    [self.webData setLength:0];
    
    [self WebServiceGetError:ConnectionFailed];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:_webData];
    [xmlParser setDelegate:self];
	[xmlParser setShouldResolveExternalEntities:YES];
	[xmlParser parse];
}

#pragma mark - WebServiceProtocol

- (void)WebServiceGetCompleted
{    
    if (_timer) {
        [_timer invalidate];
        self.timer = nil;
    }
    
    if (_delegate) {
        if ([_delegate respondsToSelector:@selector(WebServiceGetCompleted:)]) {
            [_delegate WebServiceGetCompleted:self];
        }
    }
}

- (void)WebServiceGetError:(NSString *)theError
{
    if (_timer) {
        [_timer invalidate];
        self.timer = nil;
    }
    
    WebServiceFailureType type;
    if ([theError isEqualToString:ConnectionInitFailed]) {
        type = WebServiceInitFailed;
    } else if ([theError isEqualToString:ConnectionFailed]) {
        type = WebServiceConnectFailed;
    } else if ([theError isEqualToString:ConnectionTimeOut]) {
        type = WebServiceTimeOut;
    }
    
    if (_delegate) {
        if ([_delegate respondsToSelector:@selector(WebServiceGetError:type:)])
            [_delegate WebServiceGetError:self type:type];
    }
}

#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	if ([elementName isEqualToString:_webServiceResult]) {
        self.soapResults = [[NSMutableString alloc] init];
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	if (_soapResults) {
		[self.soapResults appendString:string];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	if ([elementName isEqualToString:_webServiceResult]) {
        [self WebServiceGetCompleted];
	}
}

#pragma mark - Time Out Manage

- (void)timeOut
{
    [self WebServiceGetError:ConnectionTimeOut];
}

@end
