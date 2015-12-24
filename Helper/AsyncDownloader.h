//
//  AsyncDwonder.h
//  AudioDownloader
//
//  Created by birneysky on 15/12/9.
//  Copyright © 2015年 birneysky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AsyncDownloader : NSObject <NSCopying>

@property (nonatomic,readonly) double totoalContentLength;

@property (nonatomic,readonly) long long loadedContentLength;

@property (nonatomic,readonly) BOOL isActive;

- (instancetype)initWithUrl:(NSString*)url;

- (void)start;

@end
