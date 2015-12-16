//
//  AudioCell.m
//  AudioDownloader
//
//  Created by birneysky on 15/11/19.
//  Copyright © 2015年 birneysky. All rights reserved.
//

#import "AudioCell.h"

@interface AudioCell ()
@property (weak, nonatomic) IBOutlet UIProgressView* progressView;

@end

@implementation AudioCell


- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect rect = self.frame;
    self.progressView.frame = CGRectMake(0, rect.size.height - 2, rect.size.width, 2);
}



- (void)setProgress:(CGFloat)progress
{
    self.progressView.progress = progress;
}


@end
