//
//  ViewController.m
//  AudioDownloader
//
//  Created by birneysky on 15/11/19.
//  Copyright © 2015年 birneysky. All rights reserved.
//

#import "AudioViewController.h"
#import "FeedLoader.h"
#import "AudioCell.h"
#import "DetailViewController.h"
#import "AsyncDownloader.h"
#import "ItemInfo.h"

@interface AudioViewController () <FeedLoaderDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (strong, nonatomic) NSMutableArray* dataSource;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshBtnItem;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@property (nonatomic,strong) NSMutableDictionary* processManager;

@end

@implementation AudioViewController

#pragma mark - *** Properties ***
- (NSMutableArray*)dataSource
{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

- (NSMutableDictionary*)processManager
{
    if (!_processManager) {
        _processManager = [[NSMutableDictionary alloc] init];
    }
    return _processManager;
}


#pragma mark - *** Initializers ***
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.indicator.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProcess:) name:NB_UPDATEDOWNLOADPROCESS object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - *** Api ***
- (void)setResult:(NSArray*)array
{
    self.refreshBtnItem.enabled = YES;
    [self.indicator stopAnimating];
    self.indicator.hidden = YES;
//    for (NSDictionary* dic in array) {
//        ItemInfo* info = [[ItemInfo alloc] init];
//        info.title = [[[dic objectForKey:@"title"] objectForKey:@"text"] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n "]];
//        info.keywords = [[[dic objectForKey:@"itunes:keywords"] objectForKey:@"text"] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n "]];
//        
//        info.summary = [[[dic objectForKey:@"itunes:summary"] objectForKey:@"text"] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n "]];
//        
//        info.url = [[dic objectForKey:@"enclosure"] objectForKey:@"url"];
//        info.length = [[[dic objectForKey:@"enclosure"] objectForKey:@"length"] floatValue];
//        [self.dataSource addObject:info];
//    }
    
    [self.dataSource addObjectsFromArray:array];
    
    [self.tableView reloadData];
}

#pragma mark - *** Target Action ***
- (IBAction)refreshList:(UIBarButtonItem *)sender {
    
    NSString* feedUrl = @"http://www.justing.com.cn/justpod/justpod_album_ruizhi.xml";//@"http://www.wooozy.cn/wp-content/uploads/podcast/summer/podcast.xml";
    FeedLoader* feed = [[FeedLoader alloc] init];
    [self.dataSource removeAllObjects];

    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
            [self.dataSource addObjectsFromArray:[feed doSyncRequest:feedUrl]];
            break;
        case 1:
            self.refreshBtnItem.enabled = NO;
            self.indicator.hidden = NO;
            [self.indicator startAnimating];
            [feed doQueueRequest:feedUrl delegate:self];
            break;
        default:
            break;
    }
    [self.tableView reloadData];
}

#pragma mark - *** Helper ***
- (void)configureCell:(AudioCell*)cell item:(ItemInfo*)item
{
    cell.text = item.title;
    cell.detailText = item.keywords;
    cell.progress = item.progress;
}


#pragma mark - *** TableView Data Source ***

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AudioCell* cell = [tableView dequeueReusableCellWithIdentifier:@"AudioCell"];
    ItemInfo* info = self.dataSource[indexPath.row];
    cell.text = info.title;
    cell.detailText = info.keywords;
    cell.progress = info.progress;
    return cell;
}


#pragma mark - *** TableView Delegate ***

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"showDetail" sender:indexPath];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ItemInfo* info = self.dataSource[indexPath.row];
    
    
    AsyncDownloader* downLoader = [[AsyncDownloader alloc] initWithUrl:info.url];
    [self.processManager setObject:indexPath forKey:downLoader];
    
    
    [downLoader start];
    

    
}


#pragma mark - *** Navigation ***

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showDetail"]) {
        DetailViewController* dc = segue.destinationViewController;
        NSIndexPath* path = sender;
        ItemInfo* info = self.dataSource[path.row];
        dc.detailText = info.summary;

    }
    
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    return NO;
}

#pragma mark - *** notification selector ***
- (void)updateProcess:(NSNotification*)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        AsyncDownloader* loader = notification.object;
        NSIndexPath* indexPath = self.processManager[loader];
        AudioCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
        CGFloat process = loader.loadedContentLength / loader.totoalContentLength;
        ItemInfo* info = self.dataSource[indexPath.row];
        info.progress = process;
        //[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        cell.progress = process;
    });
    
    
}

@end
