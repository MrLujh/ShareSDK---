



//
//  WXAPIManager.m
//  ShareSDK
//
//  Created by lujh on 2017/5/18.
//  Copyright © 2017年 lujh. All rights reserved.
//

#import "WXAPIManager.h"

@implementation WXAPIManager

#pragma mark - LifeCycle
+(instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static WXAPIManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [[WXAPIManager alloc] init];
    });
    return instance;
}

- (void)dealloc {
    self.delegate = nil;
}

#pragma mark -WXApiDelegate

- (void)onResp:(BaseResp *)resp {
    
    
    NSString * strMsg = [NSString stringWithFormat:@"errorCode: %d",resp.errCode];
    NSLog(@"strMsg: %@",strMsg);
    
    NSString * errStr       = [NSString stringWithFormat:@"errStr: %@",resp.errStr];
    NSLog(@"errStr: %@",errStr);
    
    
    NSString * strTitle;
    //判断是微信消息的回调
    if ([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        strTitle = [NSString stringWithFormat:@"发送媒体消息的结果"];
    }
    
    
    NSString * wxPayResult;
    //判断是否是微信支付回调 (注意是PayResp 而不是PayReq)
    if ([resp isKindOfClass:[PayResp class]])
    {
        //支付返回的结果, 实际支付结果需要去微信服务器端查询
        
        strTitle = [NSString stringWithFormat:@"支付结果"];
        
        switch (resp.errCode)
        {
            case WXSuccess:
            {
                strMsg = @"支付结果:";
                NSLog(@"支付成功: %d",resp.errCode);
                wxPayResult = @"success";
                break;
            }
            case WXErrCodeUserCancel:
            {
                strMsg = @"用户取消了支付";
                NSLog(@"用户取消支付: %d",resp.errCode);
                wxPayResult = @"cancel";
                break;
            }
            default:
            {
                strMsg = [NSString stringWithFormat:@"支付失败! code: %d  errorStr: %@",resp.errCode,resp.errStr];
                NSLog(@":支付失败: code: %d str: %@",resp.errCode,resp.errStr);
                wxPayResult = @"faile";
                break;
            }
        }
        
        //发出通知
        NSNotification * notification = [NSNotification notificationWithName:@"WXPay" object:wxPayResult];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    
        
        AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        
        if (app.weixinPay == WriteOrderWeixinPay) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kWriteOrderWeixinPay" object:[NSNumber numberWithInt:resp.errCode]];
            
        }else  if (app.weixinPay == OrderListWeixinPay) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kOrderListWeixinPay" object:[NSNumber numberWithInt:resp.errCode]];
            
        }else if (app.weixinPay == OrderDetailWeixinPay) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kOrderDetailWeixinPay" object:[NSNumber numberWithInt:resp.errCode]];
            
        }else if (app.weixinPay == DiscountBillWeixinPay) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kDiscountBillWeixinPay"
                                                                object:[NSNumber numberWithInt:resp.errCode]];
            
        }else if (app.weixinPay == KabaoWriteOrderWeixinPay) {//卡包支付
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kKabaoWeixinPay"
                                                                object:[NSNumber numberWithInt:resp.errCode]];
            
        }
    
    }
    
}


@end
