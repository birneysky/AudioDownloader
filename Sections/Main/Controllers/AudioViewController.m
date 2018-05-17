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
#import "CustomSearchController.h"
#import "ResumeableDownloader.h"

@interface AudioViewController () <FeedLoaderDelegate,DownloadItemDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (strong, nonatomic) NSMutableArray* dataSource;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshBtnItem;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (nonatomic,strong) NSMutableDictionary* processManager;
@property (nonatomic,strong) CustomSearchController* searchController;
@property (nonatomic, copy) NSString* archivePath;
@property (nonatomic, copy) NSString* archiveFileFullPath;

@end

@implementation AudioViewController
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

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

- (CustomSearchController*)searchController
{
    if (!_searchController) {
        _searchController = [[CustomSearchController alloc] initWithSearchResultsController:nil];
    }
    return _searchController;
}

- (NSString*)archivePath {
    if (!_archivePath) {
        NSString* cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
        _archivePath =[cachePath stringByAppendingPathComponent:NSStringFromClass([self class])];
    }
    return _archivePath;
}

- (NSString*)archiveFileFullPath {
    if (!_archiveFileFullPath) {
        _archiveFileFullPath = [self.archivePath stringByAppendingPathComponent:@"ItemInfos.archive"];
    }
    return _archiveFileFullPath;
}


#pragma mark - *** Initializers ***
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.indicator.hidden = YES;
    self.searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchController.searchBar.barTintColor = RGB(217, 217, 217);
  if (@available(iOS 11,*)) {
    self.navigationItem.searchController = self.searchController;
    //self.navigationItem.hidesSearchBarWhenScrolling = NO;
  } else {
    self.tableView.tableHeaderView = self.searchController.searchBar;
  }

    [self createDirectoryIfNeed];
    self.definesPresentationContext = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
    NSArray<ItemInfo*>* items = [NSKeyedUnarchiver unarchiveObjectWithFile:self.archiveFileFullPath];
    [items makeObjectsPerformSelector:@selector(resetState)];
    [self.dataSource addObjectsFromArray:items];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProcess:) name:NB_UPDATEDOWNLOADPROCESS object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NB_UPDATEDOWNLOADPROCESS object:nil];
  self.title = @"";
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
    NSArray<ItemInfo*>* itemInfos = array;
    [itemInfos makeObjectsPerformSelector:@selector(titleTextTrim)];
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
    
    [self.dataSource addObjectsFromArray:itemInfos];
    
    [self.tableView reloadData];
}

#pragma mark - *** Target Action ***
- (IBAction)refreshList:(UIBarButtonItem *)sender {
    
    //NSString* feedUrl = @"http://www.justing.com.cn/justpod/justpod_album_ruizhi.xml";
    NSString* feedUrl = @"http://www.wooozy.cn/wp-content/uploads/podcast/summer/podcast.xml";
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

-(UIColor*)randomColor
{
    switch (arc4random() % 5) {
        case 0:return [UIColor greenColor];
        case 1:return [UIColor blueColor];
        case 2:return [UIColor orangeColor];
        case 3:return [UIColor redColor];
        case 4:return [UIColor purpleColor];
    }
    return [UIColor blackColor];
}

- (void)createDirectoryIfNeed {
    BOOL isDirectory = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExists = [fileManager fileExistsAtPath:self.archivePath isDirectory:&isDirectory];
    if (!isExists || !isDirectory) {
        [fileManager createDirectoryAtPath:self.archivePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
//    NSString* fileStorePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/MyFile"];
//    if (![fileManager fileExistsAtPath:fileStorePath]) {
//        [fileManager createDirectoryAtPath:fileStorePath withIntermediateDirectories:YES attributes:nil error:nil];
//    }
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
    //cell.detailText = info.keywords;
    cell.progress = info.progress;
    //cell.backgroundColor = [self randomColor];
    if (info.state == Waiting) {
        cell.detailText = @"Start Downloaing";
    } else if (info.state == Running) {
        cell.detailText = @"Suspend Downloading";
    } else if(info.state == Suspended) {
        cell.detailText = @"Resume Downloading";
    } else if (info.state == Completed) {
        cell.detailText = @"Dowading finish";
    } else if (info.state == Failed) {
        cell.detailText = @"Downloading failed";
    }
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
    
    NSURL* url = [NSURL URLWithString:info.url];
    DownloadItem* item = [[ResumeableDownloader defaultInstance] itemOf:url];
    if (!item) {
        item = [[DownloadItem alloc] initWithURL:url];
    }
    
    item.delegate = self;
    
    [self.processManager setObject:indexPath forKey:url];
    
    if (info.state == Waiting) {
        [[ResumeableDownloader defaultInstance] downLoad:item];
    } else if (info.state == Running) {
        [[ResumeableDownloader defaultInstance] suspend:item];
    } else if(info.state == Suspended || info.state == Failed) {
        [[ResumeableDownloader defaultInstance] resume:item];
    }
//    AsyncDownloader* downLoader = [[AsyncDownloader alloc] initWithUrl:info.url];
//    [self.processManager setObject:indexPath forKey:downLoader];
//
//
//    [downLoader start];
    
    
    
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

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    return NO;
}

#pragma mark - *** notification selector ***
- (void)updateProcess:(NSNotification*)notification {
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

- (void)appWillTerminate:(NSNotification*)notification {
    [NSKeyedArchiver archiveRootObject:self.dataSource toFile:self.archiveFileFullPath];
}

#pragma mark - DownloadItemDelegate
- (void)downItem:(DownloadItem*)item state:(RCDownloadItemState)state {
    NSIndexPath* indexPath = self.processManager[item.URL];
    NSLog(@"🤯🤯🤯🤯🤯🤯🤯🤯🤯index row %ld state %ld",(long)indexPath.row,(long)state);
    ItemInfo* info = (ItemInfo*)self.dataSource[indexPath.row];
    info.state = (ItemInfoState)state;
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}
- (void)downItem:(DownloadItem*)item progress:(float)progress {
    NSIndexPath* indexPath = self.processManager[item.URL];
    NSLog(@"🤯🤯🤯🤯🤯🤯🤯🤯🤯index row %ld progress %f",(long)indexPath.row,progress);
    ItemInfo* info = (ItemInfo*)self.dataSource[indexPath.row];
    info.progress = progress;
    AudioCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.progress = progress;
}
- (void)downItem:(DownloadItem*)item didCompleteWithError:(NSError*)error filePath:(NSString*)path {
    NSIndexPath* indexPath = self.processManager[item.URL];
    NSLog(@"🤯🤯🤯🤯🤯🤯🤯🤯🤯index row %ld didCompleteWithError %@, filePath %@",(long)indexPath.row,error,path);
    ItemInfo* info = (ItemInfo*)self.dataSource[indexPath.row];
    if (!error) {
        info.state = Completed;
    } else {
        info.state = Failed;
    }
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
