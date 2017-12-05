//
//  DoRCConversationViewController.m
//  doDebuger
//
//  Created by zmj on 2017/4/21.
//  Copyright © 2017年 deviceone. All rights reserved.
//

#import "DoRCConversationViewController.h"
#import "UIColor+DORCColor.h"
#import "doInvokeResult.h"
#import "do_RongUtil.h"
#import <RongIMKit/RongIMKit.h>

@interface DoRCConversationViewController ()
@property (nonatomic, assign) BOOL navigationBarHidden;
@end

@implementation DoRCConversationViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:false animated:false];
    _navigationBarHidden = true;
    
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:_navigationBarHidden animated:false];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _navigationBarHidden = true;
    // Do any additional setup after loading the view.
    UIView *fillView = [[UIView alloc] initWithFrame:CGRectMake(0, -20,[UIScreen mainScreen].bounds.size.width, 20)];
    fillView.backgroundColor = self.titleBarColor ? self.titleBarColor : [UIColor blueColor];
    [self.navigationController.navigationBar addSubview:fillView];
    
    //    self.automaticallyAdjustsScrollViewInsets = YES;
    // 导航栏背景色
    [self.navigationController.navigationBar setBackgroundImage:[UIColor imageWithColor:[UIColor clearColor]] forBarMetrics:UIBarMetricsDefault];
    UIColor *bgColor = self.titleBarColor ? self.titleBarColor : [UIColor blueColor];
    self.navigationController.navigationBar.backgroundColor = bgColor;
    UIImageView *assistShowNavBgColorImageView = [[UIImageView alloc] initWithImage:[UIColor imageWithColor:bgColor]];
    assistShowNavBgColorImageView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 20);
    [self.view addSubview:assistShowNavBgColorImageView];
    
    // 导航栏标题颜色
    NSDictionary *titleAttriDict = self.titleColor ? @{NSForegroundColorAttributeName:self.titleColor} : @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    [self.navigationController.navigationBar setTitleTextAttributes: titleAttriDict];
    
    // 自定义返回按钮
    UIImage *backImg = [[UIImage imageNamed:@"do_rong_conversation_nav_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:backImg style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    if (self.targetUserName != nil) {
        self.navigationItem.title = self.targetUserName;
    }
    
    if (self.conversationType != ConversationType_APPSERVICE &&
        self.conversationType != ConversationType_PUBLICSERVICE) {
        //加号区域增加发送文件功能，Kit中已经默认实现了该功能，但是为了SDK向后兼容性，目前SDK默认不开启该入口，可以参考以下代码在加号区域中增加发送文件功能。
        UIImage *imageFile = [RCKitUtility imageNamed:@"actionbar_file_icon" ofBundle:@"RongCloud.bundle"];
        [self.chatSessionInputBarControl.pluginBoardView insertItemWithImage:imageFile
                                                                       title:NSLocalizedStringFromTable(@"File", @"RongCloudKit", nil)
                                                                     atIndex:3
                                                                         tag:PLUGIN_BOARD_ITEM_FILE_TAG];
    }
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
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

#pragma mark - override method
- (void)didTapCellPortrait:(NSString *)userId {
    RCUserInfo *userInfo = [[RCIM sharedRCIM] getUserInfoCache:userId];
    NSString *userName;
    if (userInfo) {
        userName = userInfo.name;
    }else {
        userName = @"";
    }
    doInvokeResult *result = [[doInvokeResult alloc] init];
    NSString *conversationType = [[do_RongUtil shareInstance] conversationTypeStringWithRCConversationType:self.conversationType];
    [result SetResultNode:@{@"conversationType":conversationType,@"userId":userId,@"userName":userName}];
    [self.eventCenter FireEvent:@"userPortraitClick" :result];
}

- (void)didTapMessageCell:(RCMessageModel *)model {
    if ([model.objectName isEqualToString:@"RC:FileMsg"]) { // 即将跳转查看文件页面
        _navigationBarHidden = false;
    }
    [super didTapMessageCell:model];
}


@end
