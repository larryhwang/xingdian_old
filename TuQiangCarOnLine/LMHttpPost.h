//
//  LMHttpPost.h
//  中科
//
//  Created by apple on 14-3-3.
//  Copyright (c) 2014年 thinkrace. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LMHttpPost : NSObject

- (void)getResponseWithName:(NSString *)URLString
                 parameters:(NSDictionary *)parameters
                    success:(void (^)(id responseObject))success
                    failure:(void (^)(NSError *error))failure;

@end
