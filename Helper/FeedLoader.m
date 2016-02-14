//
//  FeedLoader.m
//  AudioDownloader
//
//  Created by birneysky on 15/11/19.
//  Copyright © 2015年 birneysky. All rights reserved.
//

#import "FeedLoader.h"
#import "XMLReader.h"
#include "ItemInfo.h"

@interface FeedLoader ()
@property (nonatomic,strong) NSOperationQueue* queue;
@end

@implementation FeedLoader

#pragma mark - *** Properties ***
- (NSOperationQueue*)queue
{
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
    }
    return _queue;
}


#pragma mark - *** Api ***
- (NSArray*)getEntitiesArray:(NSDictionary*)dictinary
{
    NSArray* entities = [[[dictinary objectForKey:@"rss"] objectForKey:@"channel"] objectForKey:@"item"];

    NSMutableArray* array = [[NSMutableArray alloc] init];
    for (NSDictionary* dic in entities) {
        ItemInfo* info = [[ItemInfo alloc] init];
        info.title = [[[dic objectForKey:@"title"] objectForKey:@"text"] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n "]];
        info.keywords = [[[dic objectForKey:@"itunes:keywords"] objectForKey:@"text"] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n "]];
        
        info.summary = [[[dic objectForKey:@"itunes:summary"] objectForKey:@"text"] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n "]];
        
        info.url = [[dic objectForKey:@"enclosure"] objectForKey:@"url"];
        info.length = [[[dic objectForKey:@"enclosure"] objectForKey:@"length"] floatValue];
        [array addObject:info];
    }
    
    return [array copy];
}

// 执行一个同步请求，加载指定url内容
- (NSArray *) doSyncRequest:(NSString *)urlString
{
    // 根据string 创建URL对象
    NSURL* url = [NSURL URLWithString:urlString];
    
    // 创建请求对象，超时30秒，总是重新获取 ,忽视缓冲
    NSURLRequest* request = [NSURLRequest requestWithURL:url
                                        cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                        timeoutInterval:30.0f];
    //发送请求，并且等待响应
    NSHTTPURLResponse* response;
    NSError* error;
    
    NSData* data = [NSURLConnection sendSynchronousRequest:request
                                   returningResponse:&response
                                             error:&error];

    // 检查错误
    if (error) {
        NSLog(@"Error on load = %@",error.localizedDescription);
        return nil;
    }
    
    //检查http状态
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        if (200 != httpResponse.statusCode) {
            return nil;
        }
        NSLog(@"Header = %@",httpResponse.allHeaderFields);
    }
    
    //解析数据到字典
    NSDictionary* dictinary = [XMLReader dictionaryForXMLData:data error:&error];
    NSLog(@"feed = %@", dictinary);
    
    
    return [self getEntitiesArray:dictinary];
}


// 执行一个队列式异步请求
- (NSArray*)doQueueRequest:(NSString*)urlString delegate:(id<FeedLoaderDelegate>)delegate
{
    // 根据string 创建URL对象
    NSURL* url = [NSURL URLWithString:urlString];
    // 创建请求对象，超时30秒，总是重新获取 ,忽视缓冲
    NSURLRequest* request = [NSURLRequest requestWithURL:url
                                       cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                      timeoutInterval:30.0f];
    // 发送一部请求
    NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession* urlSession = [NSURLSession sessionWithConfiguration:sessionConfig];
    NSURLSessionDataTask* task = [urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // 检查错误
        if (error) {
            NSLog(@" erro  on load = %@",[error localizedDescription]);
        }
        else
        {
            //检查http状态
            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                if (200 != httpResponse.statusCode) {
                    return;
                }
                
                NSLog(@"Header = %@",httpResponse.allHeaderFields);
            }
            
            //解析数据到字典
            NSDictionary* dataDic = [XMLReader dictionaryForXMLData:data error:&error];
            NSArray* dataArray = [self getEntitiesArray:dataDic];
            
            if ([delegate respondsToSelector:@selector(setResult:)]) {
                //                                   [delegate performSelectorOnMainThread:@selector(setResult:)
                //                                                           withObject:dataArray
                //                                                           waitUntilDone:NO];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate setResult:dataArray];
                });
            }
            
        }

    }];
    [task resume];
//    [NSURLConnection sendAsynchronousRequest:request
//                                queue:self.queue
//                       completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
//                           // 检查错误
//                           if (connectionError) {
//                               NSLog(@" erro  on load = %@",[connectionError localizedDescription]);
//                           }
//                           else
//                           {
//                               //检查http状态
//                               if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
//                                   NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
//                                   if (200 != httpResponse.statusCode) {
//                                       return;
//                                   }
//                                   
//                                   NSLog(@"Header = %@",httpResponse.allHeaderFields);
//                               }
//                               
//                               //解析数据到字典
//                               NSDictionary* dataDic = [XMLReader dictionaryForXMLData:data error:&connectionError];
//                               NSArray* dataArray = [self getEntitiesArray:dataDic];
//                               
//                               if ([delegate respondsToSelector:@selector(setResult:)]) {
////                                   [delegate performSelectorOnMainThread:@selector(setResult:)
////                                                           withObject:dataArray
////                                                           waitUntilDone:NO];
//                                   dispatch_async(dispatch_get_main_queue(), ^{
//                                       [delegate setResult:dataArray];
//                                   });
//                               }
//                               
//                           }
//        
//    }];
//    
    
    
    return nil;
}

@end
