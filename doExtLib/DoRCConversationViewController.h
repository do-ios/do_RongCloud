//
//  DoRCConversationViewController.h
//  doDebuger
//
//  Created by zmj on 2017/4/21.
//  Copyright © 2017年 deviceone. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>
#import "doEventCenter.h"
@interface DoRCConversationViewController : RCConversationViewController
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIColor *titleBarColor;
@property (nonatomic, strong) NSString *targetUserName;
@property (nonatomic, strong) doEventCenter *eventCenter;
@end
