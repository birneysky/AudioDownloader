//
//  AudioCell.m
//  AudioDownloader
//
//  Created by birneysky on 15/11/19.
//  Copyright © 2015年 birneysky. All rights reserved.
//

#import "AudioCell.h"

@implementation AudioCell


- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect rect = self.frame;
    self.processView.frame = CGRectMake(0, rect.size.height - 2, rect.size.width, 2);
}

@end
