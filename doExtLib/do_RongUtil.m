//
//  do_RongUtil.m
//  doDebuger
//
//  Created by zmj on 2017/5/9.
//  Copyright © 2017年 deviceone. All rights reserved.
//

#import "do_RongUtil.h"

@implementation do_RongUtil

+ (do_RongUtil *)shareInstance {
    static do_RongUtil *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

- (NSString*)conversationTypeStringWithRCConversationType: (RCConversationType)type {
    NSString *typeStr = @"";
    switch (type) {
        case ConversationType_PRIVATE:
            typeStr =  @"private";
            break;
        case ConversationType_GROUP:
            typeStr = @"group";
            break;
        default:
            break;
    }
    return typeStr;
}
@end
