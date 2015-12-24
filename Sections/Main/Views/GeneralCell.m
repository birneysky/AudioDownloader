//
//  GeneralCell.m
//  AudioDownloader
//
//  Created by birneysky on 15/12/16.
//  Copyright © 2015年 birneysky. All rights reserved.
//

#import "GeneralCell.h"

@implementation GeneralCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setText:(NSString *)text
{
    self.textLabel.text = text;
}

- (void)setDetailText:(NSString *)detailText
{
    self.detailTextLabel.text = detailText;
}

@end
