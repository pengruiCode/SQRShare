//
//  PRShare.m
//  PRHudIndicator
//
//  Created by macMini on 2018/1/24.
//  Copyright © 2018年 PR. All rights reserved.
//

#import "PRShareView.h"
#import "PRSharePlatform.h"
#import "PRContentSeparateButton.h"
/**
 导入ShareSDK分享功能
*/
#import <ShareSDK/ShareSDK.h>
//#import <ShareSDKUI/ShareSDK+SSUI.h>
#import <ShareSDKConnector/ShareSDKConnector.h>

//腾讯开放平台（对应QQ和QQ空间）SDK头文件
//#import <TencentOpenAPI/TencentOAuth.h>
//#import <TencentOpenAPI/QQApiInterface.h>

//微信SDK头文件
@class WXApi;

// 获取屏幕尺寸
#define kScreenWidth ([UIScreen mainScreen].bounds.size.width)
#define kScreenHeight ([UIScreen mainScreen].bounds.size.height)

static CGFloat const buttonHeight = 90.f;
static CGFloat const buttonWith = 76.f;
static CGFloat const heightSpace = 15.f;                        //竖间距
static CGFloat const cancelHeight = 46.f;

@interface PRShareView () <UIGestureRecognizerDelegate>

@property (nonatomic,strong) UIView *bottomPopView;             //底部view
@property (nonatomic,strong) NSMutableArray *platformArray;     //分享项目模型
@property (nonatomic,strong) NSMutableArray *buttonArray;       //按钮
@property (nonatomic,assign) PRShareType shareConentType;       //分享类型
@property (nonatomic,assign) CGFloat shreViewHeight;            //分享视图的高度
@property (nonatomic,assign) SSDKPlatformType shareType;        //分享类型
@property (nonatomic,strong) NSMutableDictionary *shareParams;  //分享参数
@property (nonatomic,strong) NSString *shareUrl;                //分享链接（用于粘贴板）

@end

@implementation PRShareView

static id _instance;

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] initWithFrame:DEF_Window.bounds];
    });
    return _instance;
}


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.platformArray = [NSMutableArray array];
        self.buttonArray = [NSMutableArray array];
        
        //初始化分享平台
        [self setUpPlatformsItems];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
        tapGestureRecognizer.delegate = self;
        [tapGestureRecognizer addTarget:self action:@selector(close)];
        [self addGestureRecognizer:tapGestureRecognizer];
        
        //计算分享视图的总高度
        self.shreViewHeight = heightSpace *(self.platformArray.count /4 + 2) + buttonHeight * (self.platformArray.count /4 + 1) + cancelHeight;
        
        int columnCount=4;
        //计算间隙
        CGFloat appMargin=(kScreenWidth - columnCount * buttonWith)/(columnCount + 1);
        
        for (int i=0; i < self.platformArray.count; i++) {
            
            PRSharePlatform *platform = self.platformArray[i];
            //计算列号和行号
            int colX=i%columnCount;
            int rowY=i/columnCount;
            //计算坐标
            CGFloat buttonX = appMargin+colX*(buttonWith + appMargin);
            CGFloat buttonY = heightSpace + rowY * (buttonHeight + heightSpace);
            PRContentSeparateButton *shareBut = [[PRContentSeparateButton alloc] init];
            [shareBut setTitle:platform.name forState:UIControlStateNormal];
            [shareBut setImage:[UIImage imageNamed:platform.iconNormal] forState:UIControlStateNormal];
            [shareBut setImage:[UIImage imageNamed:platform.iconHighlighted] forState:UIControlStateHighlighted];
            shareBut.frame = CGRectMake(10, 10, 76, 90);
            [shareBut addTarget:self action:@selector(clickShare:) forControlEvents:UIControlEventTouchUpInside];
            shareBut.tag = platform.shareType;//这句话必须写！！！
            [self.bottomPopView addSubview:shareBut];
            shareBut.frame = CGRectMake(buttonX, buttonY, buttonWith, buttonHeight);
            [self.bottomPopView addSubview:shareBut];
            [self.buttonArray addObject:shareBut];
            
        }
        
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelButton setFrame:CGRectMake(0, self.shreViewHeight - cancelHeight, kScreenWidth, cancelHeight)];
        [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        cancelButton.titleLabel.font = [UIFont systemFontOfSize:16.0f];
        [cancelButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomPopView addSubview:cancelButton];
        
        CALayer *lineLayer = [CALayer layer];
        lineLayer.frame =CGRectMake(cancelButton.frame.size.width * 0.1, 0, cancelButton.frame.size.width * 0.8, 0.5);
        lineLayer.backgroundColor = [UIColor whiteColor].CGColor;
        [cancelButton.layer addSublayer:lineLayer];
        
        [self addSubview:self.bottomPopView];
        
    }
    return self;
}

- (UIView *)bottomPopView {
    if (!_bottomPopView) {
        _bottomPopView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, self.shreViewHeight)];
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        effectView.frame = CGRectMake(0, 0, _bottomPopView.frame.size.width, _bottomPopView.frame.size.height);
        [_bottomPopView addSubview:effectView];
    }
    return _bottomPopView;
}


+ (void)setShareSdk {
    [ShareSDK registerActivePlatforms:@[@(SSDKPlatformTypeWechat)]
                            onImport:^(SSDKPlatformType platformType) {
        switch (platformType){
            case SSDKPlatformTypeWechat:
                [ShareSDKConnector connectWeChat:[WXApi class]];
                break;
            default:
                break;
        }
    }onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo) {
        switch (platformType){
            case SSDKPlatformTypeWechat:
                [appInfo SSDKSetupWeChatByAppId:WXApi_APPKEY
                                      appSecret:ShareSDK_WeChat_appSecret];
                break;
            default:
                break;
        }
     }];
}


- (void)shareParamsTitle:(NSString *)title
                  images:(id)images
                     url:(NSString *)url
                    text:(NSString *)text {
        _shareParams = [NSMutableDictionary dictionary];
        self.shareUrl = url;
        [_shareParams SSDKSetupShareParamsByText:text ? text : @""
                                         images:images
                                            url:[NSURL URLWithString:url]
                                          title:title ? title : title
                                           type:SSDKContentTypeAuto];
}

#pragma mark --- 点击了分享按钮
- (void)clickShare:(UIButton *)sender {
    switch (sender.tag) {
        case PRShareTypeWechatSession://微信好友
        {
            _shareType = SSDKPlatformSubTypeWechatSession;
        }
            break;
        case PRShareTypeWechatTimeline://微信朋友圈
        {
            _shareType = SSDKPlatformSubTypeWechatTimeline;
        }
            break;
        case PRShareTypeQQ://QQ好友
        {
            _shareType = SSDKPlatformSubTypeQQFriend;
        }
            break;
        case PRShareTypeQzone://QQ空间
        {
            _shareType = SSDKPlatformSubTypeQZone;
        }
            break;
        case PRShareTypeUrl://复制链接
        {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = self.shareUrl;
            DEF_Toast(@"复制成功");
            return;
        }
            break;
        default:
            break;
    }
    
    /*
     调用shareSDK的无UI分享类型，
     */
    
    if (!_shareParams) {
        DEF_Toast(@"没有设置分享参数！");
        return;
    }
    
    [ShareSDK share:_shareType parameters:_shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
        
        
        switch (state) {
            case SSDKResponseStateSuccess:
            {
                if (self.shareReturnBlock) {
                    self.shareReturnBlock(0);
                }
                DEF_Toast(@"分享成功！");
                break;
            }
                
            case SSDKResponseStateFail:
            {
                if (self.shareReturnBlock) {
                    self.shareReturnBlock(1);
                }
                DEF_Toast(@"分享失败！");
                break;
            }
                
            case SSDKResponseStateCancel:
            {
                if (self.shareReturnBlock) {
                    self.shareReturnBlock(2);
                }
                break;
            }
            default:
                break;
        }
        
        
        
    }];
    [self close];
}


- (void)shareReturnBlock:(shareReturnBlock)block {
    self.shareReturnBlock = block;
}



#pragma mark --- 设置平台 (防止审核失败 最好要先判断是否已安装微信、QQ 或其他平台的App)
-(void)setUpPlatformsItems {
    //微信好友
    PRSharePlatform *wechatSessionModel = [[PRSharePlatform alloc] init];
    wechatSessionModel.iconNormal = @"weixin_allshare";
    wechatSessionModel.iconHighlighted = @"weixin_allshare_night";
    wechatSessionModel.shareType = PRShareTypeWechatSession;
    wechatSessionModel.name = @"微信好友";
    [self.platformArray addObject:wechatSessionModel];
    
    //微信朋友圈
    PRSharePlatform *wechatTimeLineModel = [[PRSharePlatform alloc] init];
    wechatTimeLineModel.iconNormal = @"pyq_allshare";
    wechatTimeLineModel.iconHighlighted = @"pyq_allshare_night";
    wechatTimeLineModel.shareType = PRShareTypeWechatTimeline;
    wechatTimeLineModel.name = @"微信朋友圈";
    [self.platformArray addObject:wechatTimeLineModel];
    
//    //QQ好友
//    PRSharePlatform *qqModel = [[PRSharePlatform alloc] init];
//    qqModel.iconNormal = @"qq_allshare";
//    qqModel.iconHighlighted = @"qq_allshare_night";
//    qqModel.shareType = PRShareTypeQQ;
//    qqModel.name = @"QQ好友";
//    [self.platformArray addObject:qqModel];
//    
//    //QQ空间
//    PRSharePlatform *qqZone = [[PRSharePlatform alloc] init];
//    qqZone.iconNormal = @"qqzone_allshare";
//    qqZone.iconHighlighted = @"qqzone_allshare_night";
//    qqZone.shareType = PRShareTypeQzone;
//    qqZone.name = @"QQ空间";
//    [self.platformArray addObject:qqZone];
    
    //复制链接
    PRSharePlatform *urlModel = [[PRSharePlatform alloc] init];
    urlModel.iconNormal = @"link_allshare";
    urlModel.iconHighlighted = @"link_allshare_night";
    urlModel.shareType = PRShareTypeUrl;
    urlModel.name = @"复制链接";
    [self.platformArray addObject:urlModel];
}

#pragma mark --- UIGestureRecognizerDelegate 监听手势，只响应背景
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isDescendantOfView:self.bottomPopView]) {
        return NO;
    }
    return YES;
}


#pragma mark --- 显示背景视图
- (void)show {
    self.backgroundColor = [UIColor clearColor];
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [UIView animateWithDuration:.3f animations:^{
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.4f];
        self.bottomPopView.frame = CGRectMake(0, kScreenHeight - self.shreViewHeight, kScreenWidth, self.shreViewHeight);
    }];
    
    //按钮动画
    for (PRContentSeparateButton *button in self.buttonArray) {
        NSInteger idx = [self.buttonArray indexOfObject:button];
        
        CGAffineTransform fromTransform = CGAffineTransformMakeTranslation(0, 50);
        button.transform = fromTransform;
        button.alpha = 0.3;
        
        [UIView animateWithDuration:0.9+idx*0.1 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:1.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            button.transform = CGAffineTransformIdentity;
            button.alpha = 1;
        } completion:^(BOOL finished) {
            
        }];
        
    }
}

#pragma mark --- 关闭背景视图
- (void)close {
    [UIView animateWithDuration:.3f animations:^{
        self.backgroundColor = [UIColor clearColor];
        self.bottomPopView.frame = CGRectMake(0, kScreenHeight, kScreenWidth, self.shreViewHeight);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [self.shareParams removeAllObjects];
    }];
}

@end
