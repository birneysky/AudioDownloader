//
//  AsyncDwonder.h
//  AudioDownloader
//
//  Created by birneysky on 15/12/9.
//  Copyright © 2015年 birneysky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AsyncDwonder : NSObject

@property (nonatomic,copy) NSString* url;

- (void)start;

@end
