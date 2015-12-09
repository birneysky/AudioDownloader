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

@interface AudioViewController () <FeedLoaderDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (strong, nonatomic) NSMutableArray* dataSource;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshBtnItem;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
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

#pragma mark - *** Initializers ***
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.indicator.hidden = YES;
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


#pragma mark - *** TableView Data Source ***

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AudioCell* cell = [tableView dequeueReusableCellWithIdentifier:@"AudioCell"];

    
    cell.textLabel.text = [[[self.dataSource[indexPath.row] objectForKey:@"title"] objectForKey:@"text"] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n "]];
    cell.detailTextLabel.text = [[[self.dataSource[indexPath.row] objectForKey:@"itunes:keywords"] objectForKey:@"text"] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n "]];
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
}


#pragma mark - *** Navigation ***

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showDetail"]) {
        DetailViewController* dc = segue.destinationViewController;
        NSIndexPath* path = sender;
        dc.detailText = [[[self.dataSource[path.row] objectForKey:@"itunes:subtitle"] objectForKey:@"text"] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n "]];

    }
    
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    NSLog(@" shouldPerformSegueWithIdentifier %@",identifier);
    return NO;
}




@end
