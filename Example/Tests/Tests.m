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

//- (void)setUp
//{
//    [super setUp];
//    // Put setup code here. This method is called before the invocation of each test method in the class.
//}
//
//- (void)tearDown
//{
//    // Put teardown code here. This method is called after the invocation of each test method in the class.
//    [super tearDown];
//}
//
//- (void)testGET{
//    id ex = [self expectationWithDescription:@""];
//    
//    [AYHttp.client executeRequest:[AYHttpRequest GET:@"https://api.github.com/search/repositories"
//                                          withParams:@{
//                                                       @"q": @"AYHttp"
//                                                       }]]
//    .then(^(AYHttpResponse *response){
//        XCTAssert(response.responseJson);
//    }).catch(^(NSError *error){
//        
//        XCTAssert(NO, @"should be success");
//    }).always(^{
//        [ex fulfill];
//    });
//    
//    [self waitForExpectationsWithTimeout:TIME_OUT handler:nil];
//}
//
//- (void)testGETError{
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
//}
//
//- (void)testPOST{
//    id ex = [self expectationWithDescription:@""];
//    
//    [AYHttp.client executeRequest:[AYHttpRequest POST:@"http://api.fir.im/apps"
//                                           withParams:@{
//                                                        @"type": @"ios",
//                                                        @"bundle_id": @"cn.yerl.aa",
//                                                        @"api_token": @"f156b688dd49f664d85a5c5eac6597d4"
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
//}
//
//- (void)testPOSTError{
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
//}
//
//- (void)testUPLOAD{
//    id ex = [self expectationWithDescription:@""];
//    
//    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"aaa" ofType:@"zip"]];
//    
//    AYHttpRequest *uploadRequest = [AYHttpRequest POST:@"http://10.0.1.2:8080/MDDisk/file"
//                                            withParams:@{
//                                                         @"mp3": [AYHttpFileParam paramWithData:data andName:@"aaa.zip"]
//                                                         }];
//    [uploadRequest setUploadProgress:^(NSProgress * _Nonnull progress) {
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
//}
//
//- (void)testDOWNLOAD{
//    id ex = [self expectationWithDescription:@""];
//    
//    AYHttpRequest *downloadReq = [AYHttpRequest GET:@"https://cache.ruby-lang.org/pub/ruby/2.3/ruby-2.3.1.tar.gz" withParams:nil];
//    [downloadReq setDownloadProgress:^(NSProgress * _Nonnull progress) {
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
//}
//
//- (void)testResumeDownload{
//    id ex = [self expectationWithDescription:@""];
//    
//    AYHttpRequest *downloadReq = [AYHttpRequest GET:@"https://cache.ruby-lang.org/pub/ruby/2.3/ruby-2.3.1.tar.gz" withParams:nil];
//    [downloadReq setDownloadProgress:^(NSProgress * _Nonnull progress) {
//        NSLog(@"first download: %@", @(progress.fractionCompleted));
//    }];
//    
//    //first download
//    [AYHttp.client downloadRequest:downloadReq].then(^(AYHttpResponse *response){
//        XCTAssert(NO, @"should be fail");
//    }).catch(^(NSError *error){
//        NSData *data = [[error.userInfo objectForKey:AYPromiseInternalErrorsKey] userInfo][@"com.alamofire.serialization.response.error.data"];
//        NSString *tempStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        NSLog(tempStr, nil);
//    });
//    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [[AYHttp client] suspendDownloadRequest:downloadReq].then(^(AYFile *cache){
//            XCTAssert(cache != nil);
//            return cache;
//        }).thenDelay(5, ^(AYFile *cache){
//            AYHttpRequest *request = nil;
//            [[AYHttp client] resumeDownloadRequest:&request withConfig:cache].then(^(AYHttpResponse *response){
//                
//            }).catch(^(NSError *error){
//                NSData *data = [[error.userInfo objectForKey:AYPromiseInternalErrorsKey] userInfo][@"com.alamofire.serialization.response.error.data"];
//                NSString *tempStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//                NSLog(tempStr, nil);
//                XCTAssert(NO, @"should be success");
//            }).always(^{
//                [ex fulfill];
//            });
//            
//            XCTAssert(request != nil);
//            
//            [request setDownloadProgress:^(NSProgress * _Nonnull progress) {
//                NSLog(@"resume: %@", @(progress.fractionCompleted));
//            }];
//        });
//    });
//    [self waitForExpectationsWithTimeout:TIME_OUT handler:nil];
//}
//
//- (void)testHeader{
//    id ex = [self expectationWithDescription:@""];
//    
//    AYHttpRequest *request = [AYHttpRequest GET:@"http://codesync.cn/api/v3/groups" withParams:nil];
//    [request setHeaderValue:@"FtpjWQwDSEyU8YpnVsmw" forKey:@"PRIVATE-TOKEN"];
//    
//    [[AYHttp client] executeRequest:request].then(^(AYHttpResponse *resonse){
//        NSLog(@"%@", resonse.responseJson);
//    }).catch(^(NSError *error){
//        XCTAssert(NO);
//    }).always(^{
//        [ex fulfill];
//    });
//    
//    [self waitForExpectationsWithTimeout:TIME_OUT handler:nil];
//}
//
//- (void)testSharedHeader{
//    id ex = [self expectationWithDescription:@""];
//    
//    [[AYHttp client] setHeaderValue:@"FtpjWQwDSEyU8YpnVsmw" forKey:@"PRIVATE-TOKEN"];
//    
//    AYHttpRequest *request = [AYHttpRequest GET:@"http://codesync.cn/api/v3/groups" withParams:nil];
//    [[AYHttp client] executeRequest:request].then(^(AYHttpResponse *resonse){
//        NSLog(@"%@", resonse.responseJson);
//    }).catch(^(NSError *error){
//        XCTAssert(NO);
//    }).always(^{
//        [ex fulfill];
//    });
//    
//    [self waitForExpectationsWithTimeout:TIME_OUT handler:nil];
//}

@end

