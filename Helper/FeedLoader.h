//
//  FeedLoader.h
//  AudioDownloader
//
//  Created by birneysky on 15/11/19.
//  Copyright © 2015年 birneysky. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FeedLoaderDelegate <NSObject>

- (void)setResult:(NSArray*)array;

@end

@interface FeedLoader : NSObject

// 执行一个同步请求，加载指定url内容
- (NSArray *) doSyncRequest:(NSString *)urlString;


// 执行一个队列式异步请求
- (NSArray*)doQueueRequest:(NSString*)urlString delegate:(id<FeedLoaderDelegate>)delegate;

@end
