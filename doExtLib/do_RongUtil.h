//
//  do_RongUtil.h
//  doDebuger
//
//  Created by zmj on 2017/5/9.
//  Copyright © 2017年 deviceone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMKit/RongIMKit.h>
@interface do_RongUtil : NSObject
+ (do_RongUtil *)shareInstance;
- (NSString*)conversationTypeStringWithRCConversationType: (RCConversationType)type;
@end
