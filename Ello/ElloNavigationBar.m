//
//  ElloNavigationBar.m
//  Ello
//
//  Created by vd-rahim on 11/11/17.
//  Copyright © 2017 vd-rahim. All rights reserved.
//

#import "ElloNavigationBar.h"

@interface ElloNavigationBar ()

@end

@implementation ElloNavigationBar

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavBarButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupNavBarButton{
    //self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"yourimage.png"]];
    _leftBarButtonUserSetting.layer.cornerRadius = _leftBarButtonUserSetting.bounds.size.width/2;
    _leftBarButtonUserSetting.layer.masksToBounds = YES;
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
