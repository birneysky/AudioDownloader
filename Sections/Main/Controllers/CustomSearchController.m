//
//  CustomSearchController.m
//  AudioDownloader
//
//  Created by birneysky on 16/1/9.
//  Copyright © 2016年 birneysky. All rights reserved.
//

#import "CustomSearchController.h"

@interface CustomSearchController ()

@property (nonatomic,strong) UIVisualEffectView* effectView;

@end

@implementation CustomSearchController

#pragma mark - *** Properties ***
- (UIVisualEffectView*)effectView
{
    if (!_effectView) {
       // _effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        //_effectView.alpha = 0.5;
    }
    return _effectView;
}


#pragma mark - *** Initializer ***
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[self.view addSubview:self.effectView];
    // Do any additional setup after loading the view.
}

- (void)viewWillLayoutSubviews
{
    self.effectView.frame = self.view.frame;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
