//
//  AsyncDwonder.m
//  AudioDownloader
//
//  Created by birneysky on 15/12/9.
//  Copyright © 2015年 birneysky. All rights reserved.
//

#import "AsyncDwonder.h"

@interface AsyncDwonder ()

@property(nonatomic,strong) NSURLConnection* connection;

@end

@implementation AsyncDwonder

- (void)start
{
    NSURL* url = [NSURL URLWithString:self.url];
    
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    
    self.connection =  [NSURLConnection connectionWithRequest:request delegate:self];
}

@end
