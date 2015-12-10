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
     DebugLog(@" self frame = %@",NSStringFromCGRect(self.frame));
    CGRect rect = self.frame;
    self.processView.frame = CGRectMake(0, rect.size.height - 2, rect.size.width, 2);
    DebugLog(@" process =  %@",NSStringFromCGRect(self.processView.frame));
}

@end
