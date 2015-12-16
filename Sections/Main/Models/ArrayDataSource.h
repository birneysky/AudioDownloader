//
//  ArrayDataSource.h
//  AudioDownloader
//
//  Created by birneysky on 15/12/16.
//  Copyright © 2015年 birneysky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^configureCell)(UITableViewCell* cell, id dataInfo);

@interface ArrayDataSource : NSObject

- (instancetype)initWithCellIdentifier:(NSString*)identify
           configureCellBlock:(configureCell)block;


- (void)addItem:(id)item;

@end
