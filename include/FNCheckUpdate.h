//
//  FNCheckUpdate.h
//  libFNUtilsDemo
//
//  Created by YijingNiu on 13-10-16.
//  Copyright (c) 2013年 YijingNiu. All rights reserved.
//
/*
******声明：本类修改自互联网上“何振东”的“CheckUpdate”类,对其进行优化修改,并且去除了ASIHttp的与JSonkit的依赖,适用ios 5及以上版本
*QQ:372726799
*Sina Weibo:黑苹果X
*Web:http://www.icesources.com
*/
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@protocol FNCheckUpdateDelegate <NSObject>

@optional
/*
canUpdate YES代表有可用更新  NO代表没有可用更新 此方法为可选方法
 */
-(void)hasNewVersion:(BOOL)canUpdate;


@end
@interface FNCheckUpdate : NSObject<UIAlertViewDelegate,NSURLConnectionDelegate,NSURLConnectionDataDelegate>

/*
 设置委托
 */
@property (assign, nonatomic) id <FNCheckUpdateDelegate>  delegate;

/*
 forceUpdate YES代表强制更新  NO 代表非强制更新
 */
@property (assign, nonatomic) BOOL  forceUpdate;


/*
 获取单例对象
 */
+ (FNCheckUpdate *)shareInstance;


/*
外部调用checkUpdateWithAppID方法来检测是否有更新版本
 appID是一串纯数字的编号 例如：656505553
 */
- (void)checkUpdateWithAppID:(NSString*)appID;


@end
