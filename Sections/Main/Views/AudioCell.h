//
//  AudioCell.h
//  AudioDownloader
//
//  Created by birneysky on 15/11/19.
//  Copyright © 2015年 birneysky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AudioCell : UITableViewCell

@property (nonatomic,copy) NSString* text;

@property (nonatomic,copy) NSString* detailText;

@property (nonatomic,assign) CGFloat progress;

@end
