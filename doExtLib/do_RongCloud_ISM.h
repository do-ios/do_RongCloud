//
//  do_RongCloud_IMethod.h
//  DoExt_API
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol do_RongCloud_ISM <NSObject>

//实现同步或异步方法，parms中包含了所需用的属性
@required
- (void)addFriends:(NSArray *)parms;
// 同步
- (void)setTitleBarColor:(NSArray *)parms;
- (void)setTitleColor:(NSArray *)parms;
- (void)logout:(NSArray *)parms;
- (void)getLatestMessage:(NSArray *)parms;
- (void)cacheUserInfo:(NSArray *)parms;
- (void)cacheGroupInfo:(NSArray *)parms;
// 异步
- (void)login:(NSArray *)parms;
- (void)openConversation:(NSArray *)parms;
- (void)openConversationList:(NSArray *)parms;
- (void)openGroupConversation:(NSArray *)parms;
- (void)setUserInfo:(NSArray *)parms;
- (void)sendTextMessage:(NSArray *)parms;

@end
