//
//  FirstUseViewController.m
//  XMLL2
//
//  Created by zzddn on 2017/1/22.
//  Copyright © 2017年 zzddn. All rights reserved.
//

#import "FirstUseViewController.h"
#import "FirstUseView.h"
#import "RegisterViewController.h"
@interface FirstUseViewController ()
//宏定义firstUseView
#define firstUseView [FirstUseView sharedView]
@end

@implementation FirstUseViewController

- (void)loadView{
    [[FirstUseView sharedView] viewAddTo:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //添加点击事件
    [firstUseView.registerBtn addTarget:self action:@selector(BtnDidTouch:) forControlEvents:UIControlEventTouchUpInside];
    [firstUseView.loginBtn addTarget:self action:@selector(BtnDidTouch:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated{
    //回到开始页面的时候要把导航条隐藏
     self.navigationController.navigationBar.hidden = YES;
}

- (void)BtnDidTouch:(UIButton *)sender{
    //根据button的标题来部署导航条的标题，然后根据导航条的标题来部署是注册还是登录页面，有点像是网页中的get请求吧
    RegisterViewController *registerVC = [[RegisterViewController alloc]init];
    self.navigationController.navigationBar.hidden = NO;
        registerVC.navigationItem.title = sender.currentTitle;
        [self.navigationController pushViewController:registerVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
