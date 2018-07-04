//
//  PRShare.h
//  PRHudIndicator
//
//  Created by macMini on 2018/1/24.
//  Copyright © 2018年 PR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger , PRShareType) {
    PRShareTypeWechatSession    = 1,               //微信好友
    PRShareTypeWechatTimeline   = 2,               //微信朋友圈
    PRShareTypeWechatCollect    = 3,               //微信收藏
    PRShareTypeWechatMiniApp    = 4,               //微信小程序
    PRShareTypeQQ               = 5,               //QQ好友
    PRShareTypeQzone            = 6,               //QQ空间
    PRShareTypeUrl              = 7,               //复制链接
};

/**
 * 返回分享状态 0/1/2 成功／失败／取消
 */
typedef void(^shareReturnBlock)(NSInteger shareState);

@interface PRShareView : UIView

@property (nonatomic,strong) shareReturnBlock shareReturnBlock;

/**
 * 全局设置分享参数(在appdelegate)
 * params mobKey                分享注册key
 * params wechatKey             微信key
 * params wechatAppSecretKey    微信签名key
 * params qqAppKey              qqkey
 * params qqAppId               qq注册ID
 */
+ (void)setShareSdkParamsMobKey:(NSString *)mobKey
                      wechatKey:(NSString *)wechatKey
             wechatAppSecretKey:(NSString *)wechatAppSecretKey
                       qqAppKey:(NSString *)qqAppKey
                        qqAppId:(NSString *)qqAppId;

/**
 * 本次分享参数
 * title        标题
 * images       图片
 * url          链接
 * text         描述
 * path         分享小程序点击进入的路径，其他途径传空
 */
- (void)shareParamsTitle:(NSString *)title
                  images:(id)images
                     url:(NSString *)url
                    text:(NSString *)text
             miniAppPath:(NSString *)path;

+ (instancetype)sharedInstance;

- (void)shareReturnBlock:(shareReturnBlock)block;

- (void)show;

- (void)close;

@end
