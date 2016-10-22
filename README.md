# AYHttp

[![CI Status](http://img.shields.io/travis/alan-yeh/AYHttp.svg?style=flat)](https://travis-ci.org/alan-yeh/AYHttp)
[![Version](https://img.shields.io/cocoapods/v/AYHttp.svg?style=flat)](http://cocoapods.org/pods/AYHttp)
[![License](https://img.shields.io/cocoapods/l/AYHttp.svg?style=flat)](http://cocoapods.org/pods/AYHttp)
[![Platform](https://img.shields.io/cocoapods/p/AYHttp.svg?style=flat)](http://cocoapods.org/pods/AYHttp)

## 引用
　　使用[CocoaPods](http://cocoapods.org)可以很方便地引入AYHttp。Podfile添加AYHttp的依赖。

```ruby
pod "AYHttp"
```

## 简介
　　AYHttp是基于AFNetworking的网络请求框架。使用Promise语法进行操作，可以令代码更清晰和方便。同时，AYHttp简化了网络请求，使用起来非常简洁。

## 用例

### GET请求

```objective-c
    [AYHttp.client executeRequest:[AYHttpRequest GET:@"https://api.github.com/search/repositories"
                                          withParams:@{@"q": @"AYHttp"}]]
    .then(^(AYHttpResponse *response){
        //请求成功
        NSDictionary *result = response.responseJson;
        //其它业务
    }).catch(^(NSError *error){
        NSLog(error.localizedDescription);
    });
```

### URL Param
　　Restful风格的api常常使用URL param，AYHttp对此类URL做了处理。

```objective-c
    [[AYHttp client] executeRequest:[AYHttpRequest GET:@"https://api.douban.com/v2/book/{bookID}" withParams:@{@"bookID": bookID}]]
    .then(^(AYHttpResponse *response){
        //请求成功
        NSDictionary *result = response.responseJson;
        //其它业务
    }).catch(^(NSError *error){
        NSLog(error.localizedDescription);
    });
```
　　AYHttp会自动将url中的`{xxxx}`替换成params中的对应key的参数值，同时将params对应的key移除。

### 文件上传
```objective-c
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"aaa" ofType:@"zip"]];
    
    AYHttpRequest *uploadRequest = [AYHttpRequest POST:@"http://10.0.1.2:8080/MDDisk/file"
                                            withParams:@{
                                                         @"file": [AYHttpFileParam paramWithData:data andName:@"aaa.zip"]
                                                         }];
    [uploadRequest setUploadProgress:^(NSProgress * _Nonnull progress) {
        ///上传进度
        NSLog(@"%@", progress);
    }];
    
    [AYHttp.client executeRequest:uploadRequest]
    .then(^(AYHttpResponse *response){
        //上传成功
        NSDictionary *result = response.responseJson;
        //其它业务
    }).catch(^(NSError *error){
        //上传失败
        NSLog(error.localizedDescription);
    });
```

### 文件下载

　　文件下载分两种，分别是普通下载和断点下载。

#### 普通下载
　　使用executeRequest。下载成功后，在AYHttpResponse的`responseData`属性中获得数据。

#### 断点下载
　　使用downloadRequest。下载成功后，在AYHttpResponse的`responseFile`属性中获得文件。

```objective-c
    AYHttpRequest *downloadReq = [AYHttpRequest GET:@"https://cache.ruby-lang.org/pub/ruby/2.3/ruby-2.3.1.tar.gz" withParams:nil];
    
    [downloadReq setDownloadProgress:^(NSProgress * _Nonnull progress) {
        //下载进度
        NSLog(@"%@", progress);
    }];
    
    [AYHttp.client downloadRequest:downloadReq].then(^(AYHttpResponse *response){
        //下载成功
        NSLog(@"%@", response.responseFile);
    }).catch(^(NSError *error){
        //下载失败
        NSLog(error.localizedDescription);
    });
```

#### 断点续传
- 暂停下载，使用then可以获取暂停后生成的`暂存数据文件`。

```objective-c
    [[AYHttp client] suspendDownloadRequest:downloadReq].then(^(AYFile *config){
        NSLog(@"%@", config);
    });
```

- 断点续传，使用暂停下载时生成的`暂存数据文件`，可以继续下载。

```objective-c
    AYHttpRequest *request = nil;
    [[AYHttp client] resumeDownloadRequest:&request withConfig:config].then(^(AYHttpResponse *response){
        //下载成功
        NSLog(@"%@", response.responseFile);
    }).catch(^(NSError *error){
        //下载失败
        NSLog(error.localizedDescription);
    });
    [request setDownloadProgress:^(NSProgress * _Nonnull progress) {
        //下载进度
        NSLog(@"%@", progress);
    }];
```

## License

AYHttp is available under the MIT license. See the LICENSE file for more info.
