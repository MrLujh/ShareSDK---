//
//  AppDelegate.h
//  ShareSDK
//
//  Created by lujh on 2017/4/6.
//  Copyright © 2017年 lujh. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, WeixinPay)
{
    WriteOrderWeixinPay  = 1,
    OrderListWeixinPay   = 2,
    OrderDetailWeixinPay = 3,
    DiscountBillWeixinPay = 4,
    KabaoWriteOrderWeixinPay = 5
};

@interface AppDelegate : UIResponder <UIApplicationDelegate,WXApiDelegate>

@property (strong, nonatomic) UIWindow *window;

@property(nonatomic,assign)NSInteger  weixinPay;

@end

