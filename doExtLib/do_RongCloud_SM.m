//
//  do_RongCloud_SM.m
//  DoExt_API
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import "do_RongCloud_SM.h"

#import "doScriptEngineHelper.h"
#import "doIScriptEngine.h"
#import "doInvokeResult.h"
#import "doJsonHelper.h"
#import "doIPageView.h"
#import "doIPage.h"
#import "doServiceContainer.h"
#import "doLogEngine.h"
#import "doUIModuleHelper.h"
#import <RongIMKit/RongIMKit.h>
#import "DoRCConversationListViewController.h"
#import "DoRCConversationViewController.h"
#import "doIOHelper.h"
#import "do_RongUtil.h"
@interface do_RongCloud_SM()<RCIMReceiveMessageDelegate>

@property (nonatomic, strong) NSString *titleColor;
@property (nonatomic, strong) NSString *titleBarColor;
@property (nonatomic, strong) NSString *currentUserId;

@end



@implementation do_RongCloud_SM
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initRong];
    }
    return self;
    
}

- (void)initRong
{
    
    [RCIM sharedRCIM].receiveMessageDelegate = self;
    [RCIM sharedRCIM].enablePersistentUserInfoCache = true;
    //    //开启输入状态监听
    //    [RCIM sharedRCIM].enableTypingStatus = YES;
    //
    //    //开启发送已读回执
    //    [RCIM sharedRCIM].enabledReadReceiptConversationTypeList = @[@(ConversationType_PRIVATE)];
    //
    //    //开启多端未读状态同步
    //    [RCIM sharedRCIM].enableSyncReadStatus = YES;
    //
    //
    //    //开启消息@功能（只支持群聊和讨论组, App需要实现群成员数据源groupMemberDataSource）
    //    [RCIM sharedRCIM].enableMessageMentioned = YES;
    //
    //    //开启消息撤回功能
    //    [RCIM sharedRCIM].enableMessageRecall = YES;
    
    _currentUserId = @"";
}

- (void)Dispose {
    [super Dispose];
    _currentUserId = @"";
}

#pragma mark - log

- (void)logErrorInfo:(NSString*)errorInfo {
    [[doServiceContainer Instance].LogEngine WriteError:nil :errorInfo];
}

#pragma mark - 方法
#pragma mark - 同步异步方法的实现

//同步
- (void)setTitleBarColor:(NSArray *)parms
{
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    _titleBarColor = [doJsonHelper GetOneText:_dictParas :@"color" :@""];
}
- (void)setTitleColor:(NSArray *)parms
{
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    _titleColor = [doJsonHelper GetOneText:_dictParas :@"color" :@""];
}

- (void)logout:(NSArray *)parms {
    [[RCIM sharedRCIM] logout];
}

- (void)getLatestMessage:(NSArray *)parms {
    doInvokeResult *_invokeResult = [parms objectAtIndex:2];
    NSArray *conversationList = [[RCIMClient sharedRCIMClient]
                                 getConversationList:@[@(ConversationType_PRIVATE),@(ConversationType_GROUP)]];
    NSMutableArray *resultArray = [NSMutableArray array];
    for (RCConversation *conversation in conversationList) {
        NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
        [resultDict setObject:conversation.targetId forKey:@"userId"];
        
        NSString *message = @"";
        
        RCMessageContent *messageContent = conversation.lastestMessage;
        if ([messageContent isKindOfClass:[RCImageMessage class]]) { // 图片消息
            message = @"[图片]";
        }else if ([messageContent isKindOfClass:[RCFileMessage class]]) { //  文件消息
            message = @"[文件]";
            
        }else if ([messageContent isKindOfClass:[RCVoiceMessage class]]) { // 语音消息
            message = @"[语音]";
            
        }else if ([messageContent isKindOfClass:[RCLocationMessage class]]) { // 位置消息
            message = @"[位置]";
            
        }else if ([messageContent isKindOfClass:[RCTextMessage class]]) {  // 文本消息
            message = ((RCTextMessage*)messageContent).content;
        }
        [resultDict setObject:message forKey:@"message"];
        
        [resultDict setObject:[NSString stringWithFormat:@"%lld",conversation.sentTime] forKey:@"sentTime"];
        [resultDict setObject:[NSString stringWithFormat:@"%lld",conversation.receivedTime] forKey:@"receivedTime"];
        
        if (conversation.lastestMessageDirection == MessageDirection_SEND) { // 当前消息为发送
            if ((conversation.sentStatus == SentStatus_SENT) || (conversation.sentStatus == SentStatus_RECEIVED) || (conversation.sentStatus == SentStatus_READ) || (conversation.sentStatus == SentStatus_DESTROYED)) {
                [resultDict setObject:[NSNumber numberWithBool:true] forKey:@"isSend"];
            }else {
                [resultDict setObject:[NSNumber numberWithBool:false] forKey:@"isSend"];
                
            }
        }
        
        [resultArray addObject:resultDict];
    }
    [_invokeResult SetResultArray:resultArray];
    
}

- (void)cacheUserInfo:(NSArray *)parms {
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
    doInvokeResult * _invokeResult = [parms objectAtIndex:2];
    
    NSString *userId = [doJsonHelper GetOneText:_dictParas :@"userId" :nil];
    NSString *nickName = [doJsonHelper GetOneText:_dictParas :@"nickName" :nil];
    NSString *headPortrait = [doJsonHelper GetOneText:_dictParas :@"headPortrait" :nil];
    
    if (userId == nil || nickName == nil || headPortrait == nil) {
        [_invokeResult SetResultBoolean:false];
        [self logErrorInfo:@"cacheUserInfo: \"userId\"、\"nickName\"、\"headPortrait\"参数必传,请检查参数"];
        return;
    }
    
    if ([userId isEqualToString:@""] || [nickName isEqualToString:@""] || [headPortrait isEqualToString:@""]) {
        [_invokeResult SetResultBoolean:false];
        [self logErrorInfo:@"cacheUserInfo: \"userId\"、\"nickName\"、\"headPortrait\"参数不能为空字符串,请检查参数"];
        return;
    }
    
    if ([self isLocalFilePath:headPortrait]) {
        headPortrait = [doIOHelper GetLocalFileFullPath:_scritEngine.CurrentPage.CurrentApp :headPortrait];
    }else if (!([headPortrait hasPrefix:@"http://"] || [headPortrait hasPrefix:@"https://"] || [headPortrait hasSuffix:@"www."])) {
        [_invokeResult SetResultBoolean:false];
        [self logErrorInfo:@"cacheUserInfo: \"headPortrait\"参数只支持data、source目录和网络路径"];
        return;
    }
    
    @try {
        RCUserInfo *userInfo = [[RCUserInfo alloc] initWithUserId:userId name:nickName portrait:headPortrait];
        [[RCIM sharedRCIM] refreshUserInfoCache:userInfo withUserId:userId];
        [_invokeResult SetResultBoolean:true];
    }@catch(NSException *exception) {
        [_invokeResult SetResultBoolean:false];
    }
    
}

- (void)cacheGroupInfo:(NSArray *)parms {
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
    doInvokeResult * _invokeResult = [parms objectAtIndex:2];
    
    NSString *groupId = [doJsonHelper GetOneText:_dictParas :@"groupId" :nil];
    NSString *groupName = [doJsonHelper GetOneText:_dictParas :@"groupName" :nil];
    NSString *headPortrait = [doJsonHelper GetOneText:_dictParas :@"headPortrait" :nil];
    
    if (groupId == nil || groupName == nil || headPortrait == nil) {
        [_invokeResult SetResultBoolean:false];
        [self logErrorInfo:@"cacheGroupInfo: \"groupId\"、\"groupName\"、\"headPortrait\"参数必传,请检查参数"];
        return;
    }
    
    if ([groupId isEqualToString:@""] || [groupName isEqualToString:@""] || [headPortrait isEqualToString:@""]) {
        [_invokeResult SetResultBoolean:false];
        [self logErrorInfo:@"cacheGroupInfo: \"groupId\"、\"groupName\"、\"headPortrait\"参数不能为空字符串,请检查参数"];
        return;
    }
    
    if ([self isLocalFilePath:headPortrait]) {
        headPortrait = [doIOHelper GetLocalFileFullPath:_scritEngine.CurrentPage.CurrentApp :headPortrait];
    }else if (!([headPortrait hasPrefix:@"http://"] || [headPortrait hasPrefix:@"https://"] || [headPortrait hasSuffix:@"www."])) {
        [_invokeResult SetResultBoolean:false];
        [self logErrorInfo:@"cacheGroupInfo: \"headPortrait\"参数只支持data、source目录和网络路径"];
        return;
    }
    
    @try {
        RCGroup *group = [[RCGroup alloc] initWithGroupId:groupId groupName:groupName portraitUri:headPortrait];
        [[RCIM sharedRCIM] refreshGroupInfoCache:group withGroupId:groupId];
        [_invokeResult SetResultBoolean:true];
    }@catch(NSException *exception) {
        [_invokeResult SetResultBoolean:false];
    }
}

// 异步
- (void)login:(NSArray *)parms
{
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
    NSString *_callbackName = [parms objectAtIndex:2];
    doInvokeResult *_invokeResult = [[doInvokeResult alloc] init];
    // 融云开发平台注册的appkey
    NSString *appKey = [doJsonHelper GetOneText:_dictParas :@"appKey" :@""];
    // 当前用户token
    NSString *token = [doJsonHelper GetOneText:_dictParas :@"token" :@""];
    
    if ([appKey isEqualToString:@""] || [token isEqualToString:@""]) {
        [_invokeResult SetResultText:@"未传递appKey或token参数"];
        [_scritEngine Callback:_callbackName :_invokeResult];
        return;
    }
    
    // 初始化融云SDK 只需初始化一次
    [[RCIM sharedRCIM] initWithAppKey:appKey];
    // 连接服务器
    __weak typeof(self) weakSelf = self;
    [[RCIM sharedRCIM] connectWithToken:token success:^(NSString *userId) {
        NSLog(@"登陆成功。当前登录的用户ID：%@", userId);
        weakSelf.currentUserId = userId;
        [_invokeResult SetResultText:userId];
        [_scritEngine Callback:_callbackName :_invokeResult];
    } error:^(RCConnectErrorCode status) {
        NSLog(@"连接融云服务器错误，RCConnectErrorCode = %ld", (long)status);
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSString *errorStr = [strongSelf errorStringWithRCConnectErrorCode:status];
        [_invokeResult SetResultText:errorStr];
        [_scritEngine Callback:_callbackName :_invokeResult];
    } tokenIncorrect:^{
        [_invokeResult SetResultText:@"token过期或不正确"];
        [_scritEngine Callback:_callbackName :_invokeResult];
    }];
}

- (void)openConversationList:(NSArray *)parms
{
    id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
    NSString *_callbackName = [parms objectAtIndex:2];
    doInvokeResult *_invokeResult = [[doInvokeResult alloc] init];
    DoRCConversationListViewController *conversationListVC = [[DoRCConversationListViewController alloc] init];
    conversationListVC.titleColor = [doUIModuleHelper GetColorFromString:self.titleColor :[UIColor whiteColor]];
    conversationListVC.titleBarColor = [doUIModuleHelper GetColorFromString:self.titleBarColor :[UIColor blueColor]];
    conversationListVC.eventCenter = self.EventCenter;
    dispatch_sync(dispatch_get_main_queue(), ^{ // 切换主线程更新UI
        UIViewController *currentVC =(UIViewController*)_scritEngine.CurrentPage.PageView;
        //        [currentVC.navigationController setNavigationBarHidden:NO animated:NO];
        [currentVC.navigationController pushViewController:conversationListVC animated:true];
    });
    [_scritEngine Callback:_callbackName :_invokeResult];
}
- (void)openConversation:(NSArray *)parms
{
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
    NSString *_callbackName = [parms objectAtIndex:2];
    doInvokeResult *_invokeResult = [[doInvokeResult alloc] init];
    
    __block NSString *userId = [doJsonHelper GetOneText:_dictParas :@"userId" :@""];
    __block NSString *title = [doJsonHelper GetOneText:_dictParas :@"title" :@""];
    __block NSString *headPortrait = [doJsonHelper GetOneText:_dictParas :@"headPortrait" :@""];
    
    
    if ([userId isEqualToString:@""] || [title isEqualToString:@""]) {
        NSLog(@"userID或title不能为空");
        [[doServiceContainer Instance].LogEngine WriteError:nil :@"userID或title参数必填且不能为空"];
        [_scritEngine Callback:_callbackName :_invokeResult];
        return;
    }
    
    if ([self isLocalFilePath:headPortrait]) {
        headPortrait = [doIOHelper GetLocalFileFullPath:_scritEngine.CurrentPage.CurrentApp :headPortrait];
    }
    
    UIViewController *currentVC =(UIViewController*)_scritEngine.CurrentPage.PageView;
    // 刷新本地缓存的会话对方用户数据
    RCUserInfo *_currentUserInfo = [[RCUserInfo alloc] initWithUserId:userId
                                                                 name:title
                                                             portrait:headPortrait];
    [[RCIM sharedRCIM] refreshUserInfoCache:_currentUserInfo withUserId:_currentUserInfo.userId];
    //新建一个聊天会话View Controller对象
    DoRCConversationViewController *privateChatVC = [[DoRCConversationViewController alloc] initWithConversationType:ConversationType_PRIVATE targetId:userId];
    privateChatVC.title = title;
    // 设置颜色
    privateChatVC.titleColor = [doUIModuleHelper GetColorFromString:self.titleColor :[UIColor whiteColor]];
    privateChatVC.titleBarColor = [doUIModuleHelper GetColorFromString:self.titleBarColor :[UIColor blueColor]];
    privateChatVC.eventCenter = self.EventCenter;
    dispatch_sync(dispatch_get_main_queue(), ^{ // 切换主线程更新UI
        
        [currentVC.navigationController pushViewController:privateChatVC animated:YES];
    });
    [_scritEngine Callback:_callbackName :_invokeResult];
}
- (void)setUserInfo:(NSArray *)parms
{
    //异步耗时操作，但是不需要启动线程，框架会自动加载一个后台线程处理这个函数
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    //参数字典_dictParas
    id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
    //自己的代码实现
    
    NSString *_callbackName = [parms objectAtIndex:2];
    //回调函数名_callbackName
    doInvokeResult *_invokeResult = [[doInvokeResult alloc] init];
    //_invokeResult设置返回值
    
    //    NSString *userId = [doJsonHelper GetOneText:_dictParas :@"userId" :@""];
    NSString *nickName = [doJsonHelper GetOneText:_dictParas :@"nickName" :@""];
    NSString *headPortrait = [doJsonHelper GetOneText:_dictParas :@"headPortrait" :@""];
    if ([self isLocalFilePath:headPortrait]) {
        headPortrait = [doIOHelper GetLocalFileFullPath:_scritEngine.CurrentPage.CurrentApp :headPortrait];
    }
    
    //    userId = @"asdfg";
    //    NSString *path = [[[[NSBundle mainBundle] URLForResource:@"77" withExtension:@"png"] filePathURL] absoluteString];
    @try {
        RCUserInfo *_currentUserInfo = [[RCUserInfo alloc] initWithUserId:_currentUserId name:nickName portrait:headPortrait];
        
        [RCIM sharedRCIM].currentUserInfo = _currentUserInfo;
        [RCIM sharedRCIM].enableMessageAttachUserInfo = YES;
        
        [_invokeResult SetResultBoolean:true];
    }@catch(NSException *exception) {
        [_invokeResult SetResultBoolean:false];
    }@finally {
        [_scritEngine Callback:_callbackName :_invokeResult];
    }
}

- (void)openGroupConversation:(NSArray *)parms {
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
    NSString *_callbackName = [parms objectAtIndex:2];
    doInvokeResult *_invokeResult = [[doInvokeResult alloc] init];
    NSString *groupId = [doJsonHelper GetOneText:_dictParas :@"groupId" :@""];
    NSString *title = [doJsonHelper GetOneText:_dictParas :@"title" :@""];
    
    if ([groupId isEqualToString:@""] || [title isEqualToString:@""]) {
        NSLog(@"groupId或title不能为空");
        [[doServiceContainer Instance].LogEngine WriteError:nil :@"groupId或title参数必填且不能为空"];
        [_scritEngine Callback:_callbackName :_invokeResult];
        return;
    }
    UIViewController *currentVC =(UIViewController*)_scritEngine.CurrentPage.PageView;
    //新建一个聊天会话View Controller对象
    DoRCConversationViewController *groupChatVC = [[DoRCConversationViewController alloc] initWithConversationType:ConversationType_GROUP targetId:groupId];
    groupChatVC.title = title;
    // 设置颜色
    groupChatVC.titleColor = [doUIModuleHelper GetColorFromString:self.titleColor :[UIColor whiteColor]];
    groupChatVC.titleBarColor = [doUIModuleHelper GetColorFromString:self.titleBarColor :[UIColor blueColor]];
    groupChatVC.eventCenter = self.EventCenter;
    dispatch_sync(dispatch_get_main_queue(), ^{ // 切换主线程更新UI
        //显示聊天会话界面
        [currentVC.navigationController pushViewController:groupChatVC animated:YES];
    });
    
    [_scritEngine Callback:_callbackName :_invokeResult];
}

- (void)sendTextMessage:(NSArray *)parms {
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
    NSString *_callbackName = [parms objectAtIndex:2];
    NSString *content = [doJsonHelper GetOneText:_dictParas :@"text" :nil];
    NSString *targetId = [doJsonHelper GetOneText:_dictParas :@"targetId" :nil];
    NSString *conversationType = [doJsonHelper GetOneText:_dictParas :@"conversationType" :nil];
    NSString *pushContent = [doJsonHelper GetOneText:_dictParas :@"pushContent" :nil];
    if (content == nil) {
        [[doServiceContainer Instance].LogEngine WriteError:nil :@"text参数必填"];
        return;
    }
    if (targetId == nil) {
        [[doServiceContainer Instance].LogEngine WriteError:nil :@"targetId参数必填"];
        return;
    }
    
    RCConversationType conType;
    if (conversationType == nil) {
        [[doServiceContainer Instance].LogEngine WriteError:nil :@"conversationType参数必填"];
        return;
    }else {
        if ([conversationType isEqualToString:@"private"]) {
            conType = ConversationType_PRIVATE;
        }else if ([conversationType isEqualToString:@"group"]) {
            conType = ConversationType_GROUP;
        }else {
            [[doServiceContainer Instance].LogEngine WriteError:nil :@"conversationType参数传递有误，当前只支持priavte&group"];
            return;
        }
    }
    
    RCTextMessage *txtMsg = [RCTextMessage messageWithContent:content];
    [[RCIMClient sharedRCIMClient] sendMessage:conType targetId:targetId content:txtMsg pushContent:pushContent pushData:nil success:^(long messageId) {
        doInvokeResult *result = [[doInvokeResult alloc] init];
        [result SetResultBoolean:true];
        [_scritEngine Callback:_callbackName :result];
    } error:^(RCErrorCode nErrorCode, long messageId) {
        doInvokeResult *result = [[doInvokeResult alloc] init];
        [result SetResultBoolean:false];
        [_scritEngine Callback:_callbackName :result];
    }];
}

#pragma mark - RCIMReceiveMessageDelegate

- (void)onRCIMReceiveMessage:(RCMessage *)message left:(int)left {
    NSString *conversationType = [[do_RongUtil shareInstance] conversationTypeStringWithRCConversationType:message.conversationType];
    NSString *messageId = [NSString stringWithFormat:@"%ld",message.messageId];
    NSString *fromUserId = message.targetId;
    NSString *sendTime = [NSString stringWithFormat:@"%lld",message.sentTime];
    NSString *receiveTime = [NSString stringWithFormat:@"%lld",message.receivedTime];
    
    NSString *messageType = @"";
    
    NSString *messageContent = @"";
    
    if ([message.content isKindOfClass:[RCTextMessage class]]) {
        messageContent = ((RCTextMessage*)message.content).content;
        messageType = @"text";
    }else if ([message.content isKindOfClass:[RCLocationMessage class]]) {
        messageContent = @"位置";
        messageType = @"location";
    }else if ([message.content isKindOfClass:[RCImageMessage class]]) {
        messageContent = @"图片";
        messageType = @"image";
    }else if ([message.content isKindOfClass:[RCVoiceMessage class]]) {
        messageContent = @"语音";
        messageType = @"voice";
    }else if ([message.content isKindOfClass:[RCFileMessage class]]) {
        messageContent = @"文件";
        messageType = @"file";
    }
    
    NSMutableDictionary *messageDict = [NSMutableDictionary dictionary];
    [messageDict setValue:conversationType forKey:@"conversationType"];
    [messageDict setValue:messageId forKey:@"messageId"];
    [messageDict setValue:fromUserId forKey:@"fromUserId"];
    [messageDict setValue:sendTime forKey:@"sendTime"];
    [messageDict setValue:receiveTime forKey:@"receiveTime"];
    [messageDict setValue:messageType forKey:@"messageType"];
    [messageDict setValue:messageContent forKey:@"messageContent"];
    
    
    doInvokeResult* _invokeResult = [[doInvokeResult alloc]init:self.UniqueKey];
    [_invokeResult SetResultNode:messageDict];
    [self.EventCenter FireEvent:@"message":_invokeResult];
    
}

#pragma mark - private method
- (NSString*)errorStringWithRCConnectErrorCode:(RCConnectErrorCode)errorCode {
    NSString *errorString = @"";
    switch (errorCode) {
        case RC_CONN_ID_REJECT:
            errorString = @"appKey错误";
            break;
        case RC_CONN_TOKEN_INCORRECT:
            errorString = @"token无效";
            break;
        case RC_CONN_NOT_AUTHRORIZED:
            errorString = @"appKey与token不匹配";
            break;
        case RC_CONN_PACKAGE_NAME_INVALID:
            errorString = @"应用BundleID不正确";
            break;
        case RC_CONN_APP_BLOCKED_OR_DELETED:
            errorString = @"appKey被封禁或已经删除";
            break;
        case RC_CONN_USER_BLOCKED:
            errorString = @"用户被封禁";
            break;
        case RC_DISCONN_KICK:
            errorString = @"当前用户在其他设备已经登录,此设备被踢下线";
            break;
        case RC_CLIENT_NOT_INIT:
            errorString = @"内部错误，请联系deviceone融云组件开发人员";
            break;
        case RC_INVALID_PARAMETER:
            errorString = @"内部错误，请联系deviceone融云组件开发人员";
            break;
        case RC_CONNECTION_EXIST:
            errorString = @"连接已存在，请勿重复登录";
            break;
        case RC_INVALID_ARGUMENT:
            errorString = @"内部错误，请联系deviceone融云组件开发人员";
            break;
        default:
            break;
    }
    
    return errorString;
}

/**
 whether is local resource
 */
- (BOOL)isLocalFilePath:(NSString*)path {
    if ([path hasPrefix:@"data://"] || [path hasPrefix:@"source://"]) {
        return true;
    }
    return false;
}

@end
