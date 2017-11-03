//
//  DoRCConversionListViewController.m
//  doDebuger
//
//  Created by zmj on 2017/4/21.
//  Copyright © 2017年 deviceone. All rights reserved.
//

#import "DoRCConversationListViewController.h"
#import "DoRCConversationViewController.h"
#import "UIColor+DORCColor.h"
@interface DoRCConversationListViewController ()

@end

@implementation DoRCConversationListViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:false animated:false];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:true animated:false];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置需要显示哪些类型的会话
    // 当前只有私聊和群聊
    [self setDisplayConversationTypes:@[@(ConversationType_PRIVATE),
                                        @(ConversationType_GROUP)]];
    // 暂不要聚合
    //    //设置需要将哪些类型的会话在会话列表中聚合显示
    //    [self setCollectionConversationType:@[@(ConversationType_DISCUSSION),
    //                                          @(ConversationType_GROUP)]];
    UIView *fillView = [[UIView alloc] initWithFrame:CGRectMake(0, -20,[UIScreen mainScreen].bounds.size.width, 20)];
    fillView.backgroundColor = self.titleBarColor ? self.titleBarColor : [UIColor blueColor];
    [self.navigationController.navigationBar addSubview:fillView];
    
//    self.automaticallyAdjustsScrollViewInsets = YES;
    
    // 导航栏背景色
    [self.navigationController.navigationBar setBackgroundImage:[UIColor imageWithColor:[UIColor clearColor]] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.backgroundColor = self.titleBarColor ? self.titleBarColor : [UIColor blueColor];
    
    // 导航栏标题
    self.navigationItem.title = @"会话";
    NSDictionary *titleAttriDict = self.titleColor ? @{NSForegroundColorAttributeName:self.titleColor} : @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    [self.navigationController.navigationBar setTitleTextAttributes: titleAttriDict];
    
    // 自定义返回按钮
    UIImage *backImg = [[UIImage imageNamed:@"do_rong_conversation_nav_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:backImg style:UIBarButtonItemStylePlain target:self action:@selector(back)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

// 重写RCConversationListViewController的onSelectedTableRow事件
- (void)onSelectedTableRow:(RCConversationModelType)conversationModelType
         conversationModel:(RCConversationModel *)model
               atIndexPath:(NSIndexPath *)indexPath {
    DoRCConversationViewController *conversationVC = [[DoRCConversationViewController alloc]init];
    conversationVC.conversationType = model.conversationType;
    conversationVC.targetId = model.targetId;
    conversationVC.targetUserName = model.conversationTitle;
    conversationVC.titleBarColor = self.titleBarColor;
    conversationVC.titleColor = self.titleColor;
    conversationVC.eventCenter = self.eventCenter;
    if (model.conversationModelType == ConversationType_PRIVATE) {
        conversationVC.title = [[RCIM sharedRCIM] getUserInfoCache:model.targetId].name;
    }else if (model.conversationModelType == ConversationType_GROUP) {
        conversationVC.title = [[RCIM sharedRCIM] getGroupInfoCache:model.targetId].groupName;
    }
    [self.navigationController pushViewController:conversationVC animated:YES];
}



@end
