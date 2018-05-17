//
//  RCEDownloadItem.m
//  RongEnterpriseApp
//
//  Created by zhaobingdong on 2018/5/15.
//  Copyright © 2018年 rongcloud. All rights reserved.
//

#import "DownloadItem.h"

@interface DownloadItem ()
@property (nonatomic,weak) NSURLSessionDataTask *dataTask;
@property (nonatomic,strong) NSOutputStream *outputStream;
@property (nonatomic,assign) NSInteger totalLength;
@property (nonatomic,assign) NSInteger currentLength;
@property (nonatomic,strong) NSURL *URL;
@property (nonatomic,assign) long messageId;
@property (nonatomic,assign) RCDownloadItemState state;
@end

@implementation DownloadItem

-(instancetype)initWithURL:(NSURL*)url {
    if (self = [super init]) {
        self.URL = url;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.URL = [aDecoder decodeObjectForKey:@"URL"];
        self.messageId = [[aDecoder decodeObjectForKey:@"messageId"] longValue];
        self.state = [[aDecoder decodeObjectForKey:@"state"] integerValue];
        self.totalLength = [[aDecoder decodeObjectForKey:@"totalLength"] integerValue];
        self.currentLength = [[aDecoder decodeObjectForKey:@"currentLength"] integerValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.URL forKey:@"URL"];
    [aCoder encodeObject:@(self.messageId) forKey:@"messageId"];
    [aCoder encodeObject:@(self.state) forKey:@"state"];
    [aCoder encodeObject:@(self.totalLength) forKey:@"totalLength"];
    [aCoder encodeObject:@(self.currentLength) forKey:@"currentLength"];
}
@end
