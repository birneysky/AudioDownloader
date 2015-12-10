//
//  AsyncDwonder.m
//  AudioDownloader
//
//  Created by birneysky on 15/12/9.
//  Copyright © 2015年 birneysky. All rights reserved.
//

#import "AsyncDwonder.h"

@interface AsyncDwonder ()<NSURLConnectionDataDelegate>

@property(nonatomic,strong) NSURLConnection* connection;

@end

@implementation AsyncDwonder

- (void)start
{
    NSURL* url = [NSURL URLWithString:self.url];
    
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    
    self.connection =  [NSURLConnection connectionWithRequest:request delegate:self];
}

/*出错*/
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
}

/*分片返回数据*/
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    
}

/*当下载对象载入充分足够数据时，返回NSURLResponse对象
 在极少数情况下，比如http载入数据的类型为“multipart/x-mixed-replace”，该方法会被至少调用一次，
 这时应该处理或者丢弃由 connection:didReceiveData:投递的数据*/
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
}

/*成功载入数据后，完成*/
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
}

@end
