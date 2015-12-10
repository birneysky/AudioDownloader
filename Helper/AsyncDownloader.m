//
//  AsyncDwonder.m
//  AudioDownloader
//
//  Created by birneysky on 15/12/9.
//  Copyright © 2015年 birneysky. All rights reserved.
//

#import "AsyncDownloader.h"

@interface AsyncDownloader ()<NSURLConnectionDataDelegate>

@property(nonatomic,strong) NSURLConnection* connection;

@property (nonatomic,copy) NSString* url;

@end

@implementation AsyncDownloader

#pragma mark - *** public Api ***
- (instancetype)initWithUrl:(NSString *)url
{
    if (self = [super init]) {
        self.url = url;
    }
    return self;
}

- (void)start
{
    NSURL* url = [NSURL URLWithString:self.url];
    
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    
    self.connection =  [NSURLConnection connectionWithRequest:request delegate:self];
}


#pragma mark - *** NSURLConnectionDataDelegate **
/*出错*/
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    DebugLog(@"error %@",error);
}

/*分片返回数据*/
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    DebugLog(@" data length %lu",data.length);
}

/*当下载对象载入充分足够数据时，返回NSURLResponse对象
 在极少数情况下，比如http载入数据的类型为“multipart/x-mixed-replace”，该方法会被至少调用一次，
 这时应该处理或者丢弃由 connection:didReceiveData:投递的数据*/
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
    DebugLog(@"response %@",response);
}

/*成功载入数据后，完成*/
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    TRACE();
}

@end
