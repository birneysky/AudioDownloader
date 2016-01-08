//
//  ArrayDataSource.m
//  AudioDownloader
//
//  Created by birneysky on 15/12/16.
//  Copyright © 2015年 birneysky. All rights reserved.
//

#import "ArrayDataSource.h"

@interface ArrayDataSource ()<UITableViewDataSource>

@property (nonatomic,strong) NSMutableArray* dataSource;

@property (nonatomic,copy) NSString* cellIdentify;

@property (nonatomic,copy) configureCell block;

@end

@implementation ArrayDataSource

#pragma mark - *** Properties ***
- (NSMutableArray*)dataSource
{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}


#pragma mark - *** Initializers ***
- (instancetype)initWithCellIdentifier:(NSString*)identify
                    configureCellBlock:(configureCell)block
{
    if (self = [super init]) {
        self.cellIdentify = identify;
        self.block = block;
    }
    return self;
}


- (void)addItem:(id)item
{
    [self.dataSource addObject:item];
}

#pragma mark - *** TableView Data Source ***

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentify forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:self.cellIdentify];
    }
    
    self.block(cell,self.dataSource[indexPath.row]);
    
    return cell;
}




@end
