//
//  LMHttpPost.m
//  中科
//
//  Created by apple on 14-3-3.
//  Copyright (c) 2014年 thinkrace. All rights reserved.
//

#import "LMHttpPost.h"

//static NSString *const APIBaseURLString = @"http://www.tuqianggps.net/api/OpenAPIV3.asmx/";
//static NSString *const APIBaseURLString = @"http://api.tourrun.net/api/OpenAPIV3.asmx/";
//static NSString *const APIBaseURLString = @"http://116.204.15.53/api/OpenAPIV3.asmx/";
//static NSString *const APIBaseURLString = @"http://test.tourrun.net/API/OpenAPIV3.asmx/";
//static NSString *const APIBaseURLString = @"http://113.98.255.53:9099/api/OpenAPIV3.asmx/";
static NSString *const APIBaseURLString = @"http://www.xd-gnss.com/api/openapiv3.asmx/";

@interface LMHttpPost () <NSXMLParserDelegate>

@property (copy, nonatomic) void (^successBlock)(id responseObject);
@property (strong, nonatomic) NSMutableString *responseString;

@end

@implementation LMHttpPost

- (void)getResponseWithName:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure
{
    self.successBlock = [success copy];
    self.responseString = [[NSMutableString alloc] init];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/rss+xml"];
    [manager setResponseSerializer:[AFXMLParserResponseSerializer serializer]];
    [manager POST:[NSString stringWithFormat:@"%@%@", APIBaseURLString, URLString] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSXMLParser *parser = (NSXMLParser *)responseObject;
        parser.delegate = self;
        [parser parse];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}

#pragma mark - XML

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    [_responseString setString:@""];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [_responseString appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    NSString *clearString = [[_responseString stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[clearString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];

    if (json) {
        _successBlock(json);
    } else {
        _successBlock(clearString);
    }
}

@end
