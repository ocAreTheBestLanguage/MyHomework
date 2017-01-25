//
//  XMPPStreamManager.m
//  XMLL2
//
//  Created by zzddn on 2017/1/23.
//  Copyright © 2017年 zzddn. All rights reserved.
//

#import "XMPPStreamManager.h"
@interface XMPPStreamManager()<XMPPStreamDelegate,XMPPRosterDelegate>
@property (nonatomic,copy)NSString *password;
@property (nonatomic)BOOL hasAid;
@end
@implementation XMPPStreamManager
static XMPPStreamManager *manager;
//单例
+ (instancetype)sharedManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[XMPPStreamManager alloc]init];
    });
    return manager;
}
//xmpp流
- (XMPPStream *)xmppStream{
    if (_xmppStream == nil){
        _xmppStream = [[XMPPStream alloc]init];
        //设置属性
        _xmppStream.hostName = @"heihei.imwork.net";
        _xmppStream.hostPort = 18420;
        //设置多播代理
        [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return _xmppStream;
}
- (XMPPRoster *)roster{
    if (_roster == nil){
        _roster = [[XMPPRoster alloc]initWithRosterStorage:[XMPPRosterCoreDataStorage sharedInstance] dispatchQueue:dispatch_get_global_queue(0, 0)];
        [_roster addDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
        _roster.autoAcceptKnownPresenceSubscriptionRequests = YES;
        _roster.autoFetchRoster = YES;
    }
    return _roster;
}
- (void)loginToServerWithJID:(XMPPJID *)myJID andPassword:(NSString *)password andTitle:(NSString *)title{
    //如果用户是要注册，那么hasAid就为NO.
    if ([title isEqualToString:@"注册"]){self.hasAid = NO;}else{_hasAid = YES;}
    //要先设置了myJID才可以连接服务器
   [self.xmppStream setMyJID:myJID];
    //获取一下传过来的password
    self.password = password;
    //开始连接服务器
    [self.xmppStream connectWithTimeout:2 error:nil];
     [self.roster activate:self.xmppStream];
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender{
    if (!_hasAid){
        //没有id就注册一个
        [self.xmppStream registerWithPassword:_password error:nil];
    }else{
        [self.xmppStream authenticateWithPassword:_password error:nil];
    }
}

- (void)xmppStreamDidRegister:(XMPPStream *)sender{
    [self.xmppStream authenticateWithPassword:_password error:nil];
}
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error{
    NSDictionary *dic = [NSDictionary dictionaryWithObject:@"已有的用户名" forKey:@"status"];
    NSNotification *noti = [NSNotification notificationWithName:@"connect" object:nil userInfo:dic];
    [[NSNotificationCenter defaultCenter] postNotification:noti];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error{
    NSDictionary *dic = [NSDictionary dictionaryWithObject:@"密码错误" forKey:@"status"];
    NSNotification *noti = [NSNotification notificationWithName:@"connect" object:nil userInfo:dic];
    [[NSNotificationCenter defaultCenter] postNotification:noti];
}
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    NSDictionary *dic = [NSDictionary dictionaryWithObject:@"成功认证" forKey:@"status"];
    NSNotification *noti = [NSNotification notificationWithName:@"connect" object:nil userInfo:dic];
    [[NSNotificationCenter defaultCenter] postNotification:noti];
    
    //发送登录状态
    XMPPPresence *presence = [XMPPPresence presence];
    [presence addChild:[DDXMLElement elementWithName:@"show" stringValue:@"chat"]];
    [self.xmppStream sendElement:presence];
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{
    if ([self.delegate respondsToSelector:@selector(didReceiveMessage:andChatMessage:)]){
        [_delegate didReceiveMessage:self andChatMessage:message.body];
     }
}
- (NSArray *)array{
    if (_array == nil){
        _array = [NSMutableArray array];
    }
    return  _array;
}
- (void)xmppRoster:(XMPPRoster *)sender didRecieveRosterItem:(DDXMLElement *)item{
    NSString *jid = [[item attributeForName:@"jid"]stringValue];
    self.jid = jid;
    [self.array addObject:jid];
}

@end
