//
//  ItemInfo.h
//  AudioDownloader
//
//  Created by zhangguang on 15/12/11.
//  Copyright © 2015年 birneysky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface ItemInfo : NSObject

@property (nonatomic,copy) NSString* title;
@property (nonatomic,copy) NSString* keywords;
@property (nonatomic,copy) NSString* summary;
@property (nonatomic,copy) NSString* url;
@property (nonatomic,assign) CGFloat length;
@property (nonatomic,assign) CGFloat progress;

@end
