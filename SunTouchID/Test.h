//
//  Test.h
//  SunTouchID
//
//  Created by 孙兴祥 on 2017/9/13.
//  Copyright © 2017年 sunxiangxiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Test : NSObject{
    NSMutableDictionary        *keychainData;
    NSMutableDictionary        *genericPasswordQuery;
}

@property (nonatomic, strong) NSMutableDictionary *keychainData;
@property (nonatomic, strong) NSMutableDictionary *genericPasswordQuery;

- (void)mySetObject:(id)inObject forKey:(id)key;
- (id)myObjectForKey:(id)key;
- (void)resetKeychainItem;

@end
