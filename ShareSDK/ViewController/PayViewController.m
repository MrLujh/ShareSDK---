

//
//  PayViewController.m
//  ShareSDK
//
//  Created by lujh on 2017/4/12.
//  Copyright © 2017年 lujh. All rights reserved.
//

#import "PayViewController.h"

@interface PayViewController ()
@property(nonatomic,copy)NSDictionary *dict;
@end

@implementation PayViewController

#pragma mark 监听通知
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    //检测是否装了微信软件
    if ([WXApi isWXAppInstalled])
    {
        
        //监听通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getOrderPayResult:) name:@"WXPay" object:nil];
    }
}

#pragma mark 移除通知
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    
    //移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
}


- (IBAction)goToBuy:(UIButton *)sender {
    
    NSMutableDictionary *parms = [NSMutableDictionary dictionary];
    
    [parms setObject:@"325799" forKey:@"uid"];
    [parms setObject:@"zw91" forKey:@"username"];
    [parms setObject:@"25871" forKey:@"reid"];
    [parms setObject:@"7038116" forKey:@"shopsid"];
    [parms setObject:@"卢" forKey:@"linkman"];
    [parms setObject:@"百佳利社区1265" forKey:@"address"];
    [parms setObject:@""forKey:@"code"];
    //添加经纬度,是持续定位的经纬度
    [parms setObject:@"116.306711" forKey:@"longitude"];
    [parms setObject:@"40.036659" forKey:@"latitude"];
    [parms setObject:@"13733180662" forKey:@"phone"];
    [parms setObject:@"C291504B-4BA5-4557-84B3-6541E5BD6014" forKey:@"imei"];
    
    [parms setObject:@"3" forKey:@"payment"];
    [parms setObject:@"1" forKey:@"distri"];
    
    [parms setObject:@"" forKey:@"content"];
    [parms setObject:@"2" forKey:@"is_shop_discount"];
    [parms setObject:@"0.000000" forKey:@"freight_total_price"];
    [parms setObject:@"1.000000" forKey:@"total"];
    [parms setObject:@"1.000000" forKey:@"goods_total_price"];
    [parms setObject:@[@{@"intype": @"1",@"title":@""}] forKey:@"invoice"];
    NSMutableArray *goodsArr = [[NSMutableArray alloc]init];
    [goodsArr addObject:@{@"goodsid": @"5189549",
                          @"name": @"首尔5日炫动之旅",
                          @"price": @"1",
                          @"num": @"1",
                          @"is_special":@"2",
                          @"special_num":@"1",
                          @"special_price":@"1"}];
    [parms setObject:goodsArr forKey:@"detail"];
    
    
    [CESHttpTool requestWithURL:@"m=ApiImeiOrder&a=addorder_v3" params:[NSMutableDictionary dictionaryWithDictionary:@{@"parm": parms}] httpMethod:@"POST" completeBlock:^(id data) {
        
        NSLog(@"=========%@",data);
        
        self.dict = data;
        
        [self didTrigerTheActionOfgoPayOrder];
        
    } failedBlock:^(__autoreleasing id *error) {
        
    }];
    
    
}

//跳转到支付方式
- (void)didTrigerTheActionOfgoPayOrder
{
    //微信支付，重新支付
    
    //1.如果是微信支付，判断是否安装微信
    BOOL isWXAppInstalled = [WXApi isWXAppInstalled];
    
    if (isWXAppInstalled == NO) { //未安装，提示
        
        //        [SGInfoAlert showInfo:@"您没有安装微信,请先安装微信客户端!"
        //                      bgColor:[UIColor orangeColor].CGColor
        //                       inView:self.view vertical:0.8];
        
        return;
    }
    
    [self getWeixinPayParams];
    
}

#pragma mark -微信前支付获取微信支付参数

-(void)getWeixinPayParams{
    
    NSMutableDictionary *params =  [[NSMutableDictionary alloc] init];
    
    NSString *orderId = [self.dict objectForKey:@"id"];
    
    [params setObject:orderId forKey:@"order_id"];
    
    
    [CESHttpTool POST:@"m=ApiImeiOrder&a=wxpay_go_buy" parameters:params success:^(id responseObject) {
        
        
        NSInteger res = [[responseObject objectForKey:@"res"] integerValue];
        
        if (res == 0) {
            
            NSLog(@"111111111===%@",responseObject);
            
            [self weixinPay:responseObject];
            
            
        }else{
            
            NSString *msg = (NSString*)responseObject[@"msg"] ;
            
            //            [SGInfoAlert showInfo:msg
            //                          bgColor:[UIColor orangeColor].CGColor
            //                           inView:self.view
            //                         vertical:0.8];
            
        }
        
        
    } failure:^(NSError *error) {
        
        //        [SGInfoAlert showInfo:@"获取微信支付参数错误!"
        //                      bgColor:[UIColor orangeColor].CGColor
        //                       inView:self.view
        //                     vertical:0.8];
        
    }];
}

#pragma mark -发起微信支付

-(void)weixinPay:(NSDictionary*)data{
    
    NSString  *prepay_id = [data objectForKey:@"prepay_id"];
    NSString  *nonce_str = [data objectForKey:@"nonce_str"];
    NSString *timestamp = [data objectForKey:@"timestamp"];
    int timeStamp = -1;
    if (timestamp.length >= 1) {
        
        timeStamp = [timestamp intValue];
        
    }
    NSString *sign = [data objectForKey:@"sign"];
    
    NSLog(@"prepay_id=%@ nonce_str=%@ timestamp=%@ sign=%@",prepay_id,nonce_str,timestamp,sign);
    
    //调起微信支付
    PayReq* req             = [[PayReq alloc] init];
    req.partnerId           = @"1297546501";
    req.prepayId            = prepay_id;
    req.nonceStr            = nonce_str ;
    req.timeStamp           = timeStamp;
    req.package             = @"Sign=WXPay";
    req.sign                = sign;
    
    [WXApi sendReq:req];
    
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    app.weixinPay = WriteOrderWeixinPay;
}

#pragma mark - 事件
- (void)getOrderPayResult:(NSNotification *)notification
{
    NSLog(@"userInfo: %@",notification.userInfo);
    
    if ([notification.object isEqualToString:@"success"])
    {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示信息" message:@"支付成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
    else if([notification.object isEqualToString:@"cancel"])
    {
        [self alert:@"提示" msg:@"用户取消了支付"];
    }
    else
    {
        [self alert:@"提示" msg:@"支付失败"];
    }
}

//客户端提示信息
- (void)alert:(NSString *)title msg:(NSString *)msg
{
    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alter show];
}

@end
