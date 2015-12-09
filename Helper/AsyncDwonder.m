//
//  AsyncDwonder.m
//  AudioDownloader
//
//  Created by birneysky on 15/12/9.
//  Copyright © 2015年 birneysky. All rights reserved.
//

#import "AsyncDwonder.h"

@implementation AsyncDwonder

- (void)start
{
    NSURL* url = [NSURL URLWithString:self.url];
    
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection connectionWithRequest:request delegate:self];
}

@end
