//
//  SunKeychainTool.h
//  SunTouchID
//
//  Created by 孙兴祥 on 2017/9/13.
//  Copyright © 2017年 sunxiangxiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SunKeychainTool : NSObject

+ (instancetype)shareInstance;

/**
 存储(更新)账号和密码

 @param userName 用户名
 @param password 密码
 @return 是否存储成功：YES成功，NO失败
 */
- (BOOL)setAccount:(NSString *)userName password:(NSString *)password;

/**
 获取存储在钥匙串内对应账户的密码,可以做为查询方法，不存在返回nil

 @param userName 账户
 @return 密码,不存在是返回nil
 */
- (NSString *)getPasswordWithAccount:(NSString *)userName;

/**
 删除存储账号密码的钥匙串

 @param userName 用户名
 @return YES删除成功,NO删除失败
 */
- (BOOL)deletePasswordWithAccount:(NSString *)userName;

@end
