//
//  GeneralCell.h
//  AudioDownloader
//
//  Created by birneysky on 15/12/16.
//  Copyright © 2015年 birneysky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol GeneralCell <NSObject>

@property (nonatomic,copy) NSString* text;

@property (nonatomic,copy) NSString* detailText;

@end


@interface GeneralCell : UITableViewCell  <GeneralCell>

@property (nonatomic,copy) NSString* text;

@property (nonatomic,copy) NSString* detailText;

@end