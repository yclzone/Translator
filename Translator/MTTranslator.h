//
//  MTTranslator.h
//  Translator
//
//  Created by yclzone on 01/01/2018.
//  Copyright © 2018 YCLZONE. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^MTHandler)(id data, NSError *error);
typedef NSString *MTScope;

FOUNDATION_EXPORT MTScope const MTScopeTTS;
FOUNDATION_EXPORT MTScope const MTScopeTEXT;
FOUNDATION_EXPORT MTScope const MTScopeSPEECH;

@interface MTTranslator : NSObject
+ (instancetype)sharedTranslator;
- (void)allLanguageSupportedWithLanguage:(NSString *)language scope:(MTScope)scope completion:(MTHandler)completion;

- (void)authenticationTokenWithCompletion:(MTHandler)completon;
- (void)translateText:(NSString *)text fromLanguage:(NSString *)from toLanguage:(NSString *)to;
@end
