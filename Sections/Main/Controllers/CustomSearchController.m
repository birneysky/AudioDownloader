//
//  CustomSearchController.m
//  AudioDownloader
//
//  Created by birneysky on 16/1/9.
//  Copyright © 2016年 birneysky. All rights reserved.
//

#import "CustomSearchController.h"
#import "SearchTableViewController.h"

@interface CustomSearchController ()

@property (nonatomic,strong) UIVisualEffectView* effectView;

@end

@implementation CustomSearchController

#pragma mark - *** Properties ***
- (UIVisualEffectView*)effectView
{
    if (!_effectView) {
        _effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        //_effectView.alpha = 0.5;
    }
    return _effectView;
}


#pragma mark - *** Initializer ***
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.effectView];
  
  UIButton* leftButton = [[UIButton alloc] initWithFrame:CGRectMake(26, 100, 80, 44)];
  [leftButton setTitle:@"朋友圈" forState:UIControlStateNormal];
  [leftButton addTarget:self action:@selector(touchAction:) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:leftButton];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
  self.title = @"";
}

- (void)viewWillLayoutSubviews
{
    self.effectView.frame = self.view.frame;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - target  Action
- (void)touchAction:(UIButton*)sender {
  SearchTableViewController* viewController = [[SearchTableViewController alloc] initWithStyle:UITableViewStylePlain];
  [self.presentingViewController.navigationController pushViewController:viewController animated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
