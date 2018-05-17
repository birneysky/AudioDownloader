//
//  RCEResumeableDownloader.h
//  RongEnterpriseApp
//
//  Created by zhaobingdong on 2018/5/15.
//  Copyright © 2018年 rongcloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadItem.h"

@interface ResumeableDownloader : NSObject

+ (instancetype)defaultInstance;


/**
 下载某一个item

 @param item 待下载item的信息
 @dicussion 如果
 */
- (void)downLoad:(DownloadItem*)item;


/**
 暂停某一项下载

 @param item 下载项的信息
 */
- (void)suspend:(DownloadItem*)item;


/**
 恢复某一项下载

 @param item 下载项的信息
 */
- (void)resume:(DownloadItem*)item;


/**
 取消某一项下载

 @param item 下载项的信息
 */
- (void)cancel:(DownloadItem*)item;



- (DownloadItem*)itemOf:(NSURL*)url;


@end
