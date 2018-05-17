//
//  RCEResumeableDownloader.m
//  RongEnterpriseApp
//
//  Created by zhaobingdong on 2018/5/15.
//  Copyright © 2018年 rongcloud. All rights reserved.
//

#import "ResumeableDownloader.h"


@interface DownloadItem ()
@property (nonatomic,weak) NSURLSessionDataTask *dataTask;
@property (nonatomic,strong) NSOutputStream *outputStream;
@property (nonatomic,assign) NSInteger totalLength;
@property (nonatomic,assign) RCDownloadItemState state;
@property (nonatomic,assign) NSInteger currentLength;
@end

@interface ResumeableDownloader () <NSURLSessionDelegate>
@property (nonatomic, strong) NSURLSession *urlSession;
@property (nonatomic, strong) NSMutableDictionary<NSString*,DownloadItem*>* items;
//@property (nonatomic, copy) NSString* downloadPath;
@property (nonatomic, copy) NSString* archivePath;
@property (nonatomic, copy) NSString* archiveFileFullPath;
@end

@implementation ResumeableDownloader
#pragma mark - Properties
- (NSURLSession *)urlSession {
    
    if (!_urlSession) {
        _urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                    delegate:self
                                               delegateQueue:[[NSOperationQueue alloc] init]];
    }
    return _urlSession;
}

//- (NSString*)downloadPath {
//    if (!_downloadPath) {
//        NSString* cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
//        _downloadPath =[cachePath stringByAppendingPathComponent:NSStringFromClass([self class])];
//    }
//    return _downloadPath;
//}



- (NSString*)archivePath {
    if (!_archivePath) {
        NSString* cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
        _archivePath =[cachePath stringByAppendingPathComponent:NSStringFromClass([self class])];
    }
    return _archivePath;
}

- (NSString*)archiveFileFullPath {
    if (!_archiveFileFullPath) {
        _archiveFileFullPath = [self.archivePath stringByAppendingPathComponent:@"DownloadItems.archive"];
    }
    return _archiveFileFullPath;
}

- (NSMutableDictionary<NSString*,DownloadItem*>*)items {
    if (!_items) {
        _items = [[NSMutableDictionary alloc] initWithCapacity:10];
    }
    return _items;
}

+ (NSString*)fileNameeOfURL:(NSURL*)url {
    NSString* lastComponent = [url lastPathComponent];
    NSUInteger hash = [url hash];
    NSString* fileName = [NSString stringWithFormat:@"%lud_%@",(unsigned long)hash,lastComponent];
    return fileName;
}

- (NSString*)fileFullPathOfURL:(NSURL*)url {
    NSString* fileName = [ResumeableDownloader pathOfURL:url];
    return [NSHomeDirectory() stringByAppendingPathComponent:fileName];
}
///
+ (NSString*)pathOfURL:(NSURL*)url {
    return [@"Documents/MyFile" stringByAppendingPathComponent:url.lastPathComponent ];
}

- (NSUInteger)downloadedLength:(NSURL*)url {
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[self fileFullPathOfURL:url] error:nil];
    if (!fileAttributes) {
        return 0;
    }
    return [fileAttributes[NSFileSize] integerValue];
}

#pragma mark - Api
+ (instancetype)defaultInstance {
    static ResumeableDownloader *downloader;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        downloader = [[[self class] alloc] init];
        NSDictionary* items = [NSKeyedUnarchiver unarchiveObjectWithFile:[downloader archiveFileFullPath]];
        [downloader.items addEntriesFromDictionary:items];
    });
    return downloader;
}

- (void)downLoad:(DownloadItem*)item {

    [self createDirectoryIfNeed];
    NSURL* url = item.URL;
    
    NSString* targetFileName =  [ResumeableDownloader fileNameeOfURL:url];
    if (self.items[targetFileName]) {
        return;
    } else {
        [self.items setObject:item forKey:targetFileName];
    }
    
    NSURLSessionDataTask* task = [self downloadTask:url];
    if (task.state == NSURLSessionTaskStateRunning) {
        return;
    }
    [task resume];
    item.state = DownloadItemStateRunning;
    [item.delegate downItem:item state:DownloadItemStateRunning];
     [self archiveItems];
}

- (void)suspend:(DownloadItem*)item {
     NSURL* url = item.URL;
    NSURLSessionDataTask* task = [self downloadTask:url];
    [task suspend];
    item.state = DownloadItemStateSuspended;
    [item.delegate downItem:item state:DownloadItemStateSuspended];
     [self archiveItems];
}

- (void)resume:(DownloadItem*)item {
    NSURL* url = item.URL;
    NSURLSessionDataTask* task = [self downloadTask:url];
    [task resume];
    item.state = DownloadItemStateRunning;
    [item.delegate downItem:item state:DownloadItemStateRunning];
     [self archiveItems];
}

- (void)cancel:(DownloadItem*)item {
     NSURL* url = item.URL;
    NSURLSessionDataTask* task = [self downloadTask:url];
    [task cancel];
    item.state = DownloadItemStateCanceled;
    [item.delegate downItem:item state:DownloadItemStateCanceled];
     [self archiveItems];
}

- (DownloadItem*)itemOf:(NSURL*)url {
    NSString* targetFileName =  [ResumeableDownloader fileNameeOfURL:url];
    DownloadItem* item = self.items[targetFileName];
    return item;
}

#pragma mark - Helpers
- (NSURLSessionDataTask*)downloadTask:(NSURL*)url {
    NSString* targetFileName =  [ResumeableDownloader fileNameeOfURL:url];
    DownloadItem* item = self.items[targetFileName];
    if (!item) {
        return nil;
    }
    if (!item.dataTask) {
        NSMutableURLRequest *requestM = [NSMutableURLRequest requestWithURL:url];
        NSString* rangeValue = [NSString stringWithFormat:@"bytes=%ld-", (long)[self downloadedLength:url]];
        [requestM setValue:rangeValue forHTTPHeaderField:@"Range"];
        NSURLSessionDataTask *dataTask = [self.urlSession dataTaskWithRequest:requestM];
        dataTask.taskDescription = targetFileName;
        NSOutputStream* output = [NSOutputStream outputStreamToFileAtPath:[self fileFullPathOfURL:url] append:YES];
        item.outputStream = output;
        item.dataTask = dataTask;
        return dataTask;
    } else {
        return item.dataTask;
    }
    
}

- (void)createDirectoryIfNeed {
    BOOL isDirectory = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExists = [fileManager fileExistsAtPath:self.archivePath isDirectory:&isDirectory];
    if (!isExists || !isDirectory) {
        [fileManager createDirectoryAtPath:self.archivePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString* fileStorePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/MyFile"];
    if (![fileManager fileExistsAtPath:fileStorePath]) {
                [fileManager createDirectoryAtPath:fileStorePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

- (void)archiveItems {
    [NSKeyedArchiver archiveRootObject:self.items toFile:self.archiveFileFullPath];
}

//#pragma mark - NSURLSessionDelegate
//- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(nullable NSError *)error {
//
//}
//
//- (void)URLSession:(NSURLSession *)session
//didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
// completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
//
//}
//
//- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
//
//}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSHTTPURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    DownloadItem *item = self.items[dataTask.taskDescription];
    if (!item) {
        completionHandler(NSURLSessionResponseCancel);
        return;
    }
    [item.outputStream open];
    NSInteger thisTotalLength = response.expectedContentLength; // Equals to [response.allHeaderFields[@"Content-Length"] integerValue]
    NSInteger totalLength = thisTotalLength + [self downloadedLength:item.URL];
    item.totalLength = totalLength;

    [self archiveItems];
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    DownloadItem *item = self.items[dataTask.taskDescription];
    if (!item) {
        return;
    }
    
    [item.outputStream write:(const uint8_t *)data.bytes maxLength:data.length];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSUInteger receivedSize = [self downloadedLength:item.URL];
        NSUInteger expectedSize = item.totalLength;
        item.currentLength = receivedSize;
        float progress = 1.0 * receivedSize / expectedSize;
        [item.delegate downItem:item progress:progress];
    });
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error {
    DownloadItem *item = self.items[task.taskDescription];
    if (!item) {
        return;
    }
    
    [item.outputStream close];
    NSString* localPath = [ResumeableDownloader pathOfURL:item.URL];

    [self.items removeObjectForKey:task.taskDescription];
    dispatch_async(dispatch_get_main_queue(), ^{
        [item.delegate downItem:item didCompleteWithError:error filePath:[ResumeableDownloader pathOfURL:item.URL]];
    });
    
    [self archiveItems];
}



@end
