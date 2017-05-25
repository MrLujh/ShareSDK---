//
//  WXAPIManager.h
//  ShareSDK
//
//  Created by lujh on 2017/5/18.
//  Copyright © 2017年 lujh. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WXAPIManagerDelegate <NSObject>

@end

@interface WXAPIManager : NSObject<WXApiDelegate>

@property (nonatomic, assign) id<WXAPIManagerDelegate> delegate;

+ (instancetype)sharedManager;

@end
