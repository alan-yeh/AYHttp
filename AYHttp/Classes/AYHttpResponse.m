//
//  AYHttpResponse.m
//  AYHttp
//
//  Created by Alan Yeh on 16/7/22.
//
//

#import "AYHttpResponse.h"
#import "AYHttp_Private.h"
#import <AYFile/AYFile.h>

@implementation AYHttpResponse{
    NSData *_responseData;
    AYFile *_responseFile;
}

- (instancetype)initWithRequest:(AYHttpRequest *)request andData:(NSData *)responseData andFile:(AYFile *)responseFile{
    if (self = [super init]) {
        self.request = request;
        _responseData = responseData;
        _responseFile = responseFile;
    }
    return self;
}

- (NSURLResponse *)response{
    return self.request.task.response;
}

- (NSInteger)responseStatus{
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)self.request.task.response;
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        return response.statusCode;
    }else{
        return NSIntegerMin;
    }
}

- (NSData *)responseData{
    if (_responseData) {
        return _responseData;
    }else{
        return _responseFile.data;
    }
}

- (id)responseJson{
    if (!_responseData && !_responseFile) {
        return nil;
    }
    
    if (_responseData) {
        NSData *data = _responseData;
        if (self.request.encoding != NSUTF8StringEncoding) {
            NSString *tempStr = [[NSString alloc] initWithData:_responseData encoding:self.request.encoding];
            data = [tempStr dataUsingEncoding:NSUTF8StringEncoding];
        }
        return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    }else{
        NSLog(@"file data can not parse to json");
        return nil;
    }
}

- (NSString *)responseString{
    if (!_responseData && !_responseFile) {
        return nil;
    }
    
    if (_responseData) {
        return [[NSString alloc] initWithData:_responseData encoding:self.request.encoding];
    }else{
        NSLog(@"file data can not parse to string");
        return nil;
    }
}

- (AYFile *)responseFile{
    if (!_responseData && !_responseFile) {
        return nil;
    }
    
    if (_responseFile) {
        return _responseFile;
    }else{
        NSLog(@"response data can not parse to file");
        return nil;
    }
}

- (NSString *)description{
    return self.response.description;
}
@end
