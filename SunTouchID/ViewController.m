//
//  ViewController.m
//  SunTouchID
//
//  Created by 孙兴祥 on 2017/9/13.
//  Copyright © 2017年 sunxiangxiang. All rights reserved.
//

#import "ViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "SunKeychainTool.h"

@interface ViewController ()

@property (nonatomic,assign) BOOL isCanUseTouchID;
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (nonatomic, strong)NSString *strPriID;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.strPriID = @"test privatekey";

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

    [self.view endEditing:YES];
}

- (IBAction)avaliableAction:(UIButton *)sender {
    
    LAContext *context = [[LAContext alloc] init];
    BOOL success = [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil];
    if(success){
        NSLog(@"can use");
        _isCanUseTouchID = YES;
    }else{
        NSLog(@"can`t user ");
        _isCanUseTouchID = NO;
    }
    
}

- (IBAction)userTouchIDAction:(UIButton *)sender {
    
//    if(_isCanUseTouchID == NO){
//        return;
//    }
    
    LAContext *context = [[LAContext alloc] init];
    context.localizedFallbackTitle = @"自定义标题";
    BOOL success = [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil];
    if(success){
        NSLog(@"can use");
        if([context respondsToSelector:@selector(biometryType)])
       {
           NSLog(@"biometryType ");
           if(context.biometryType == LABiometryTypeTouchID)
           {
               NSLog(@"LABiometryTypeTouchID support");
           }
           else if (context.biometryType == LABiometryTypeFaceID)
           {
               NSLog(@"LABiometryTypeFaceID support");
           }
           else if (context.biometryType == LABiometryNone)
           {
               NSLog(@"LABiometryNone support");
           }
       }
    }
    
    [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"为什么使用TouchID写这里" reply:^(BOOL success, NSError * _Nullable error) {
       
        if(success){
            //指纹验证成功
        }else{
        
            switch (error.code) {
                case LAErrorUserFallback:{
                    NSLog(@"用户选择输入密码");
                    break;
                }
                case LAErrorAuthenticationFailed:{
                    NSLog(@"验证失败");
                    break;
                }
                case LAErrorUserCancel:{
                    NSLog(@"用户取消");
                    break;
                }
                case LAErrorSystemCancel:{
                    NSLog(@"系统取消");
                    break;
                }
                //以下三种情况如果提前检测TouchID是否可用就不会出现
                case LAErrorPasscodeNotSet:{
                    break;
                }
                //case LAErrorTouchIDNotAvailable:
                    
                    case LAErrorBiometryNotAvailable:
                        {
                            break;
                        }
           
                case LAErrorBiometryNotEnrolled:{
                    break;
                }
                    
                default:
                    break;
            }
        }
    }];
}

-(OSStatus)generateKeyAsync:(NSString *)priId
{
    CFErrorRef error = NULL;
    SecAccessControlRef __weak sacObject;
    __block OSStatus status = noErr;
    // Should be the secret invalidated when passcode is removed? If not then use `kSecAttrAccessibleWhenUnlocked`.
    
    //delete the keypair genrate before
    
    {
        NSDictionary *keygenbefore = @{
                                       (__bridge id)kSecClass: (__bridge id)kSecClassKey,
                                       (__bridge id)kSecAttrKeyClass: (__bridge id)kSecAttrKeyClassPrivate,
                                       (__bridge id)kSecAttrApplicationTag: priId,
                                       (__bridge id)kSecReturnRef: @YES                                       };
        
        SecKeyRef privateKey;
        status = SecItemCopyMatching((__bridge CFDictionaryRef)keygenbefore, (CFTypeRef *)&privateKey);
        
        status = SecItemDelete((__bridge CFDictionaryRef)keygenbefore);
    }
    
    
    
    
    //     Create parameters dictionary for key generation.
    sacObject = SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                                kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
                                                kSecAccessControlUserPresence | kSecAccessControlPrivateKeyUsage, &error);
    
    
    // Create parameters dictionary for key generation.
    NSDictionary *parameters = @{
                                 (__bridge id)kSecAttrTokenID: (__bridge id)kSecAttrTokenIDSecureEnclave,
                                 (__bridge id)kSecAttrKeyType: (__bridge id)kSecAttrKeyTypeEC,
                                 (__bridge id)kSecAttrKeySizeInBits: @256,
                                 (__bridge id)kSecPrivateKeyAttrs: @{
                                         (__bridge id)kSecAttrAccessControl: (__bridge_transfer id)sacObject,
                                         (__bridge id)kSecAttrIsPermanent: @YES,
                                         (__bridge id)kSecAttrApplicationTag: priId,
                                         }
                                 };
    
    
    // Generate key pair.
    SecKeyRef publicKey, privateKey;
    status = SecKeyGeneratePair((__bridge CFDictionaryRef)parameters, &publicKey, &privateKey);
    if (status == errSecSuccess) {
        // In your own code, here is where you'd store/use the keys.
        
//        NSDictionary *pubDict = @{
//                                  (__bridge id)kSecClass              : (__bridge id)kSecClassKey,
//                                  (__bridge id)kSecAttrKeyType        : (__bridge id)kSecAttrKeyTypeEC,
//                                  (__bridge id)kSecAttrApplicationTag :@"",
//                                  (__bridge id)kSecAttrIsPermanent    : @YES,
//                                  (__bridge id)kSecValueRef           : (__bridge id)publicKey,
//                                  (__bridge id)kSecAttrKeyClass       : (__bridge id)kSecAttrKeyClassPublic,
//                                  (__bridge id)kSecReturnData         : @YES                                  };
//        CFTypeRef dataRef = NULL;
//        status = SecItemAdd((__bridge CFDictionaryRef)pubDict, &dataRef);
//        NSData *publicdata = (__bridge NSData *)(dataRef);
//        *publickeybyte = [publicdata bytes];
    
        CFRelease(privateKey);
        CFRelease(publicKey);
    }
    else
        return -1;
    
    
    
    return status;
}

- (OSStatus)useKeyAsync:(NSString *)priId digestData:(uint8_t *)digestData
           digestLength:(size_t) digestLength
              signature:(uint8_t *)signature
        signatureLength:(size_t *)signatureLength
{
    OSStatus status = noErr;
    NSCondition *conditionlock = [[NSCondition alloc] init];
    SecKeyRef privateKey = nil;
    
    LAContext *context = [[LAContext alloc] init];
    context.localizedFallbackTitle = @"testMy";
    
    BOOL success = [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil];
    if(success){
        NSLog(@"can use");
        if([context respondsToSelector:@selector(biometryType)])
        {
            NSLog(@"biometryType ");
            if(context.biometryType == LABiometryTypeTouchID)
            {
                NSLog(@"LABiometryTypeTouchID support");
            }
            else if (context.biometryType == LABiometryTypeFaceID)
            {
                NSLog(@"LABiometryTypeFaceID support");
            }
            else if (context.biometryType == LABiometryNone)
            {
                NSLog(@"LABiometryNone support");
            }
            
        }
    }
    
    [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"为什么使用TouchID写这里" reply:^(BOOL success, NSError * _Nullable error){
        if(success == YES)
        {
            [conditionlock signal];
        }
    }];
    
    
    [conditionlock lock];
    [conditionlock wait];
    [conditionlock unlock];
    
    NSDictionary *query = @{
              (__bridge id)kSecClass: (__bridge id)kSecClassKey,
              (__bridge id)kSecAttrKeyClass: (__bridge id)kSecAttrKeyClassPrivate,
              (__bridge id)kSecAttrApplicationTag: priId,
              (__bridge id)kSecReturnRef: @YES,
              (__bridge id)kSecUseAuthenticationContext:context };
    
    
    
    status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&privateKey);
    
    if(status == noErr)
    {
        status = SecKeyRawSign(privateKey, kSecPaddingNone, digestData, digestLength, signature, signatureLength);
        NSLog(@"%s", "end CreateUAFV1RegResponse_useKeyAsyncSign\n");
    }
    else
    {
        NSLog(@"status is 0x%x", status);
    }
    
    return status;
}


- (IBAction)savePssword:(UIButton *)sender {
    
    OSStatus ret = [self generateKeyAsync:self.strPriID];
    if(ret == 0)
    {
        NSLog(@"generateKeyAsync ok");
    }
}


- (IBAction)getPassword:(UIButton *)sender {
    
    uint8_t digistHash[32] = {0};
    memset(digistHash, 0x01, 32);
    size_t digistlen = 32;
    uint8_t signdata[128] = {0};
    size_t outlen = 128;
    
    OSStatus ret = [self useKeyAsync:self.strPriID digestData:digistHash digestLength:digistlen signature:signdata signatureLength:&outlen];
    if(ret == 0)
    {
        NSLog(@"sign ok");
    }
}


- (IBAction)deleteKeychain:(UIButton *)sender {
    
 
}

@end
