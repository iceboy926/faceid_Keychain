//
//  SunKeychainTool.m
//  SunTouchID
//
//  Created by 孙兴祥 on 2017/9/13.
//  Copyright © 2017年 sunxiangxiang. All rights reserved.
//

#import "SunKeychainTool.h"
#import <Security/Security.h>

@implementation SunKeychainTool

+ (instancetype)shareInstance {

    static SunKeychainTool *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[SunKeychainTool alloc] init];
    });
    return shareInstance;
}

- (BOOL)setAccount:(NSString *)userName password:(NSString *)password {

    if(userName == nil || password == nil){
        return NO;
    }
    
    if([self getPasswordWithAccount:userName] == nil){
    
        return [self createNewKeychainWithAccount:userName password:password];
    }else{
    
        return [self updateKeychainWithAccount:userName password:password];
    }
    return NO;
}

#pragma mark - 查询账号对应的密码
- (NSString *)getPasswordWithAccount:(NSString *)userName {

    NSDictionary *attributes = @{(id)kSecClass: (id)kSecClassGenericPassword,
                                 (id)kSecAttrGeneric:[NSBundle mainBundle].bundleIdentifier,
                                 (id)kSecAttrAccount:userName,
                                 (id)kSecAttrService: @"SampleService",
                                 (id)kSecReturnData: @YES,
                                 (id)kSecReturnAttributes:@YES,
                                 (id)kSecMatchLimit:(id)kSecMatchLimitOne,
                                };

    CFMutableDictionaryRef outDictionary = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)attributes, (CFTypeRef *)&outDictionary);
    if(status == errSecSuccess){

        NSDictionary *result = (__bridge_transfer NSDictionary *)outDictionary;
        NSData *passWordData = result[(id)kSecValueData];
        if(passWordData){
            return [[NSString alloc] initWithData:passWordData encoding:NSUTF8StringEncoding];
        }
    }else{
        NSLog(@"%@",[self keychainErrorToString:status]);
    }
    return nil;
}

#pragma mark - 新建钥匙串存储账号密码
- (BOOL)createNewKeychainWithAccount:(NSString *)userName password:(NSString *)password {

    /*
     kSecClass                   //类型
     kSecAttrGeneric             //作为唯一标识
     kSecAttrService             //所具有的服务
     kSecAttrAccount             //用户名
     kSecValueData               //保存密码对应的key
     kSecAttrModificationDate    //修改日期
     */
    NSDictionary *attributes = @{(id)kSecClass: (id)kSecClassGenericPassword,
                                 (id)kSecAttrGeneric:[NSBundle mainBundle].bundleIdentifier,
                                 (id)kSecAttrService: @"SampleService",
                                 (id)kSecAttrAccount:userName,
                                 (id)kSecValueData:[password dataUsingEncoding:NSUTF8StringEncoding],
                                 (id)kSecAttrModificationDate:[NSDate date],
                                 };

    OSStatus status =  SecItemAdd((__bridge CFDictionaryRef)attributes, nil);
    if(status == errSecSuccess){
        return YES;
    }else{
        NSLog(@"%@",[self keychainErrorToString:status]);
    }
    return NO;
}

#pragma mark - 更新密码和修改时间
- (BOOL)updateKeychainWithAccount:(NSString *)userName password:(NSString *)password {

    NSDictionary *attribute = @{(id)kSecClass: (id)kSecClassGenericPassword,
                                (id)kSecAttrGeneric:[NSBundle mainBundle].bundleIdentifier,
                                (id)kSecAttrService: @"SampleService",
                                (id)kSecAttrAccount:userName,
                                };

    NSDictionary *changeDic = @{(id)kSecValueData:[password dataUsingEncoding:NSUTF8StringEncoding],
                                (id)kSecAttrModificationDate:[NSDate date]
                                };

    OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)attribute, (__bridge CFDictionaryRef)changeDic);
    if(status == errSecSuccess){
        return YES;
    }else{
        NSLog(@"%@",[self keychainErrorToString:status]);
    }
    
    return NO;
}

#pragma mark - 删除账号对应的钥匙串
- (BOOL)deletePasswordWithAccount:(NSString *)userName {

    NSDictionary *attributes = @{(id)kSecClass: (id)kSecClassGenericPassword,
                            (id)kSecAttrGeneric:[NSBundle mainBundle].bundleIdentifier,
                            (id)kSecAttrService: @"SampleService",
                            (id)kSecAttrAccount:userName
                            };

    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)attributes);
    if(status == errSecSuccess){
        return YES;
    }else{
        NSLog(@"%@",[self keychainErrorToString:status]);
    }
    return NO;
}

- (NSString *)keychainErrorToString:(OSStatus)error {
    
    NSString *message = @"error";
    
    switch (error) {
        case errSecSuccess:
            message = @"success";
            break;
            
        case errSecDuplicateItem:
            message = @"error item already exists";
            break;
            
        case errSecItemNotFound :
            message = @"error item not found";
            break;
            
        case errSecAuthFailed:
            message = @"error item authentication failed";
            break;
            
        default:
            break;
    }
    
    return message;
}

@end
