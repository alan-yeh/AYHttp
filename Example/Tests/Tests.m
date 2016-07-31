//
//  AYHttpTests.m
//  AYHttpTests
//
//  Created by Alan Yeh on 07/22/2016.
//  Copyright (c) 2016 Alan Yeh. All rights reserved.
//

@import XCTest;
#import <AYHttp/AYHttp.h>

#define TIME_OUT NSTimeIntervalSince1970

@interface Tests : XCTestCase

@end

@implementation Tests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGET{
//    id ex = [self expectationWithDescription:@""];
//    
//    [AYHttp.client executeRequest:[AYHttpRequest GET:@"http://api.fir.im/apps/latest/576107d2e75e2d717d000014"
//                                          withParams:@{
//                                                       @"api_token": @"xxxx"
//                                                       }]]
//    .then(^(AYHttpResponse *response){
//        XCTAssert(response.responseJson);
//    }).catch(^(NSError *error){
//        XCTAssert(NO, @"should be success");
//    }).always(^{
//        [ex fulfill];
//    });
//    
//    [self waitForExpectationsWithTimeout:TIME_OUT handler:nil];
}

- (void)testGETError{
//    id ex = [self expectationWithDescription:@""];
//    
//    [AYHttp.client executeRequest:[AYHttpRequest GET:@"http://api.fir.im/apps/latest/576107d2e75e2d717d000014"
//                                          withParams:nil]]
//    .then(^(AYHttpResponse *response){
//        XCTAssert(NO, @"should be fail");
//    }).catch(^(NSError *error){
//        XCTAssert(error != nil);
//    }).always(^{
//        [ex fulfill];
//    });
//    
//    [self waitForExpectationsWithTimeout:TIME_OUT handler:nil];
}

- (void)testPOST{
//    id ex = [self expectationWithDescription:@""];
//    
//    [AYHttp.client executeRequest:[AYHttpRequest POST:@"http://api.fir.im/apps"
//                                           withParams:@{
//                                                        @"type": @"ios",
//                                                        @"bundle_id": @"cn.yerl.aa",
//                                                        @"api_token": @"xxxx"
//                                                        }]]
//    .then(^(AYHttpResponse *response){
//        XCTAssert(response.responseJson);
//    }).catch(^(NSError *error){
//        NSData *data = [[error.userInfo objectForKey:AYPromiseInternalErrorsKey] userInfo][@"com.alamofire.serialization.response.error.data"];
//        NSString *tempStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        NSLog(tempStr, nil);
//        XCTAssert(NO, @"should be success");
//    }).always(^{
//        [ex fulfill];
//    });
//    
//    [self waitForExpectationsWithTimeout:TIME_OUT handler:nil];
}

- (void)testPOSTError{
//    id ex = [self expectationWithDescription:@""];
//    
//    [AYHttp.client executeRequest:[AYHttpRequest POST:@"http://api.fir.im/apps"
//                                           withParams:@{
//                                                        @"type": @"ios",
//                                                        @"bundle_id": @"cn.yerl.aa"
//                                                        }]]
//    .then(^(AYHttpResponse *response){
//        XCTAssert(NO, @"should be fail");
//    }).catch(^(NSError *error){
//        NSData *data = [[error.userInfo objectForKey:AYPromiseInternalErrorsKey] userInfo][@"com.alamofire.serialization.response.error.data"];
//        NSString *tempStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        NSLog(tempStr, nil);
//    }).always(^{
//        [ex fulfill];
//    });
//    
//    [self waitForExpectationsWithTimeout:TIME_OUT handler:nil];
}

- (void)testUPLOAD{
//    id ex = [self expectationWithDescription:@""];
//    
//    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"music" ofType:@"mp3"]];
//    
//    AYHttpRequest *uploadRequest = [AYHttpRequest POST:@"http://10.0.1.2:8080/MDDisk/file"
//                                            withParams:@{
//                                                         @"mp3": [AYHttpFileParam paramWithData:data andName:@"music.mp3"]
//                                                         }];
//    [uploadRequest setProgress:^(NSProgress * _Nonnull progress) {
//        NSLog(@"%@", progress);
//    }];
//    
//    [AYHttp.client executeRequest:uploadRequest]
//    .then(^(AYHttpResponse *response){
//        NSLog(@"%@", response.responseJson);
//        XCTAssert(response.responseJson);
//    }).catch(^(NSError *error){
//        NSData *data = [[error.userInfo objectForKey:AYPromiseInternalErrorsKey] userInfo][@"com.alamofire.serialization.response.error.data"];
//        NSString *tempStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        NSLog(tempStr, nil);
//        XCTAssert(NO, @"should be success");
//    }).always(^{
//        [ex fulfill];
//    });
//    
//    [self waitForExpectationsWithTimeout:TIME_OUT handler:nil];
}

- (void)testDOWNLOAD{
//    id ex = [self expectationWithDescription:@""];
//    
//    AYHttpRequest *downloadReq = [AYHttpRequest GET:@"https://cache.ruby-lang.org/pub/ruby/2.3/ruby-2.3.1.tar.gz" withParams:nil];
//    [downloadReq setProgress:^(NSProgress * _Nonnull progress) {
//        NSLog(@"%@", progress);
//    }];
//    
//    [AYHttp.client downloadRequest:downloadReq]
//    .then(^(AYHttpResponse *response){
//        NSLog(@"%@", response.responseFile);
//        XCTAssert(response.responseFile);
//    }).catch(^(NSError *error){
//        NSData *data = [[error.userInfo objectForKey:AYPromiseInternalErrorsKey] userInfo][@"com.alamofire.serialization.response.error.data"];
//        NSString *tempStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        NSLog(tempStr, nil);
//        XCTAssert(NO, @"should be success");
//    }).always(^{
//        [ex fulfill];
//    });
//    [self waitForExpectationsWithTimeout:TIME_OUT handler:nil];
}

- (void)testResumeDownload{
//    id ex = [self expectationWithDescription:@""];
//    
//    AYHttpRequest *downloadReq = [AYHttpRequest GET:@"http://10.0.1.2:8080/MDDisk/file/2016-07-29/cabbf287-d062-47dc-910c-df5c26cf5744.mp3" withParams:nil];
//    [downloadReq setProgress:^(NSProgress * _Nonnull progress) {
//        NSLog(@"%@", progress);
//    }];
//    
//    [AYHttp.client downloadRequest:downloadReq]
//    .then(^(AYHttpResponse *response){
//        NSLog(@"%@", response.responseFile);
//        XCTAssert(response.responseFile);
//    }).catch(^(NSError *error){
//        NSData *data = [[error.userInfo objectForKey:AYPromiseInternalErrorsKey] userInfo][@"com.alamofire.serialization.response.error.data"];
//        NSString *tempStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        NSLog(tempStr, nil);
//        XCTAssert(NO, @"should be success");
//    }).always(^{
//        [ex fulfill];
//    });
//    [self waitForExpectationsWithTimeout:TIME_OUT handler:nil];
}

@end

