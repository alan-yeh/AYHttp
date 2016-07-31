//
//  AYHttpResponse.h
//  Pods
//
//  Created by PoiSon on 16/7/22.
//
//

#import <Foundation/Foundation.h>

@class AYHttpRequest;
@class AYFile;

NS_ASSUME_NONNULL_BEGIN
@interface AYHttpResponse : NSObject
@property (retain, readonly) AYHttpRequest *request;

@property (readonly) NSDictionary<NSString *, NSString *> *headers;

@property (readonly, nullable) NSURLResponse *response;

@property (readonly) NSInteger statusCode;

@property (readonly, nullable) NSData *responseData;
@property (readonly, nullable) id responseJson;
@property (readonly, nullable) NSString *responseString;
@property (readonly, nullable) AYFile *responseFile;
@end
NS_ASSUME_NONNULL_END