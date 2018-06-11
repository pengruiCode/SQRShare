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
    PRShareTypeQQ               = 4,               //QQ好友
    PRShareTypeQzone            = 5,               //QQ空间
    PRShareTypeUrl              = 6,               //复制链接
};

/**
 * 返回分享状态 0/1/2 成功／失败／取消
 */
typedef void(^shareReturnBlock)(NSInteger shareState);

@interface PRShareView : UIView

@property (nonatomic,strong) shareReturnBlock shareReturnBlock;

//微信key和签名 (必须先传入此值)
@property (nonatomic,copy) NSString *wechatAppKey;
@property (nonatomic,copy) NSString *wechatAppSecret;
//qqkey和id
@property (nonatomic,copy) NSString *qqAppId;
@property (nonatomic,copy) NSString *qqAppKey;

/**
 * 全局设置分享参数
 */
+ (void)setShareSdk;

/**
 * 本次分享参数
 * title        标题
 * images       图片
 * url          链接
 * text         描述
 */
- (void)shareParamsTitle:(NSString *)title
                  images:(id)images
                     url:(NSString *)url
                    text:(NSString *)text;

+ (instancetype)sharedInstance;

- (void)shareReturnBlock:(shareReturnBlock)block;

- (void)show;

- (void)close;

@end
