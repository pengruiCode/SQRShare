//
//  PRSharePlatform.h
//  PRHudIndicator
//
//  Created by macMini on 2018/1/24.
//  Copyright © 2018年 PR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PRShareView.h"

@interface PRSharePlatform : NSObject

@property (nonatomic,copy) NSString *iconNormal;        //分享选项图片正常
@property (nonatomic,copy) NSString *iconHighlighted;   //分享选项图片高亮
@property (nonatomic,copy) NSString *name;              //分享选项名称
@property (nonatomic,assign) PRShareType shareType;     //分享选项类型

@end
