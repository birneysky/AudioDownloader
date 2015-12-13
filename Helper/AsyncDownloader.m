//
//  AsyncDwonder.m
//  AudioDownloader
//
//  Created by birneysky on 15/12/9.
//  Copyright © 2015年 birneysky. All rights reserved.
//

#import "AsyncDownloader.h"

@interface AsyncDownloader ()<NSURLConnectionDataDelegate>


@property (nonatomic,copy) NSString* url;

@property (nonatomic,assign) double totoalContentLength;

@property (nonatomic,assign) long long loadedContentLength;

@property (nonatomic,assign) BOOL isActive;

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

- (void)dealloc
{
    TRACE();
}

/*
 创建好连接后，代码会开始请求。在连接创建于开启之间，应用可以修改委托消息传递给委托类的方式。
 可以使指定不同的运行循环或操作队列来传递回调
 */
- (void)start
{
    NSURL* url = [NSURL URLWithString:self.url];
        
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
        //发送异步请求
    NSURLConnection* connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [connection start];
    self.isActive = YES;

//
//    dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT), ^{
//        NSRunLoop* loop = [NSRunLoop currentRunLoop];
//        
//        NSURL* url = [NSURL URLWithString:self.url];
//        NSURLRequest* request  = [NSURLRequest requestWithURL:url];
//        NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
//        //DebugLog(@"current run loop %p",[NSRunLoop currentRunLoop]);
//        //[[NSRunLoop currentRunLoop] run];
//        [connection scheduleInRunLoop:loop forMode:NSDefaultRunLoopMode];
//        [loop run];
//        [connection start];
//    });
    
}

#pragma mark - *** NSCopying **
- (id)copyWithZone:(NSZone *)zone
{
    return self;
}
#pragma mark - *** NSURLConnectionDelegate ***
/*一旦该方法调用，协议处理器将取消请求，如果临时下载文件存在，那么请关闭该文件*/
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    DebugLog(@"error %@",error);
}


#pragma mark - *** NSURLConnectionDataDelegate **

/*
 如果协议处理器接收到来自服务器的重定向请求，就会调用该方法，
 http重定向指的是，当客户端要寻找的内容位于另一个不同的URL中。
 如果应用从内容分发网络加载内容，那么重定向请求是很常见的。
 */
- (NSURLRequest*)connection:(NSURLConnection *)connection
            willSendRequest:(NSURLRequest *)request
            redirectResponse:(NSURLResponse *)response
{
    
    return request;
}

/*当协议处理器接收到部分或者全部响应体是会调用该方法，该方法可能不会被调用，也可能会被调用多次，这取决于响应体的大小。
 在每次调用时，协议处理器会再data参数中传递部分数据。该委托方法负责聚集所提供的数据对象，然后处理他们或者是将其存储起来，
 所提供的数据块大小可能与应用协议的语法边界不一致。也就是说如果代码接收的是xml文档，那么数据对象可能和文档中元素的边界不一致
 ，所以应该将受到的字节追加到数据文件中*/
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    self.loadedContentLength += data.length;
    [[NSNotificationCenter defaultCenter] postNotificationName:NB_UPDATEDOWNLOADPROCESS object:self];
    DebugLog(@" data length %lu loadedContentLength %lld",data.length,self.loadedContentLength);
}

/*当下载对象载入充分足够数据时，返回NSURLResponse对象
 在极少数情况下，比如http载入数据的类型为“multipart/x-mixed-replace”，该方法会被至少调用一次，
 这时应该处理或者丢弃由 connection:didReceiveData:投递的数据*/
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if ([response isMemberOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        self.totoalContentLength = [[[httpResponse allHeaderFields] objectForKey:@"Content-Length"] longLongValue];
        self.loadedContentLength = 0;
    }
    
    
    DebugLog(@"response %@",response);
}

/*当整个请求完成加载并且接收到得所有数据都，调用该方法。*/
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    TRACE();
}

@end
