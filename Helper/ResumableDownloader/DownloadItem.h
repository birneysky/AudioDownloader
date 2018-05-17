//
//  RCEDownloadItem.h
//  RongEnterpriseApp
//
//  Created by zhaobingdong on 2018/5/15.
//  Copyright © 2018年 rongcloud. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 下载状态枚举

 - RCEDownloadItemStateWaiting: 等待
 - RCEDownloadItemStateRunning: 正在下载
 - RCEDownloadItemStateSuspended: 暂停
 - RCEDownloadItemStateCanceled: 已取消
 - RCEDownloadItemStateCompleted: 完成
 - RCEDownloadItemStateFailed: 失败
 */
typedef NS_ENUM(NSInteger, RCDownloadItemState) {
    DownloadItemStateWaiting = 0,
    DownloadItemStateRunning,
    DownloadItemStateSuspended,
    DownloadItemStateCanceled,
    DownloadItemStateCompleted,
    DownloadItemStateFailed
};

@class DownloadItem;

@protocol DownloadItemDelegate <NSObject>
- (void)downItem:(DownloadItem*)item state:(RCDownloadItemState)state;
- (void)downItem:(DownloadItem*)item progress:(float)progress;
- (void)downItem:(DownloadItem*)item didCompleteWithError:(NSError*)error filePath:(NSString*)path;
@end


@interface DownloadItem : NSObject

-(instancetype)initWithURL:(NSURL*)url;

//@property (nonatomic,weak,readonly) NSURLSessionDataTask *dataTask;
@property (nonatomic,assign,readonly) RCDownloadItemState state;
//@property (nonatomic,strong,readonly) NSOutputStream *outputStream;
@property (nonatomic,assign,readonly) NSInteger totalLength;
@property (nonatomic,assign,readonly) NSInteger currentLength;
@property (nonatomic,strong,readonly) NSURL *URL;
@property (nonatomic,weak) id<DownloadItemDelegate> delegate;

@end

