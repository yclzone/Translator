//
//  MTTranslator.m
//  Translator
//
//  Created by yclzone on 01/01/2018.
//  Copyright © 2018 YCLZONE. All rights reserved.
//

#import "MTTranslator.h"

#ifdef DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr,"%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(...)
#endif

MTScope const MTScopeTTS = @"tts";
MTScope const MTScopeTEXT = @"text";
MTScope const MTScopeSPEECH = @"speech";

static NSString * const kMicrosoftTranslatorTextAPIKey = @"";

@implementation MTTranslator
+ (instancetype)sharedTranslator {
    static MTTranslator *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)allLanguageSupportedWithLanguage:(NSString *)language scope:(MTScope)scope completion:(MTHandler)completion {
    NSString *baseURL = @"https://dev.microsofttranslator.com/languages";
    NSString *version = @"1.0";
    NSString *urlString = [NSString stringWithFormat:@"%@?api-version=%@&scope=%@", baseURL, version, scope];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    request.URL = [NSURL URLWithString:urlString];
    request.HTTPMethod = @"GET";
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:language forHTTPHeaderField:@"Accept-Language"];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (completion) {
            completion(data, error);
        }
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        NSDictionary *singleScopeJSON = json[scope];
        
        NSArray *allKeys = singleScopeJSON.allKeys;
        allKeys = [allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [obj1 compare:obj2];
        }];
        
        if (scope == MTScopeSPEECH) {
            
            for (NSString *key in allKeys) {
                NSDictionary *lang = singleScopeJSON[key];
                NSString *name = lang[@"name"];
                NSString *language = lang[@"language"];
                NSLog(@"%@ - %@-%@", key, language, name);
            }
            
            NSLog(@"%zd", allKeys.count);
            
        } else if (scope == MTScopeTEXT) {
            
            for (NSString *key in allKeys) {
                NSDictionary *value = singleScopeJSON[key];
                NSString *dir = value[@"dir"]; // 文字方向
                NSString *name = value[@"name"];
                NSLog(@"%@-%@ %@", key, dir, name);
            }
            
            NSLog(@"%zd", allKeys.count);
            
        } else if (scope == MTScopeTTS) {
            
            NSMutableOrderedSet *regionSet = [[NSMutableOrderedSet alloc] init];
            NSMutableOrderedSet *languageSet = [[NSMutableOrderedSet alloc] init];
            for (NSString *key in allKeys) {
                NSDictionary *lang = singleScopeJSON[key];
                NSString *locale = lang[@"locale"];
                NSString *regionName = lang[@"regionName"];
                NSString *language = lang[@"language"];
                NSString *languageName = lang[@"languageName"];
                NSString *displayName = lang[@"displayName"];
                NSString *gender = lang[@"gender"];
                
                NSLog(@"%@ - %@_%@(%@)_%@_%@,", locale, language, languageName, regionName, gender, displayName);
                [languageSet addObject:locale];
                [regionSet addObject:regionName];
            }
            NSLog(@"%zd, %zd", regionSet.count, languageSet.count);
            
        }
    }];
    [task resume];
    
}

- (void)authenticationTokenWithCompletion:(MTHandler)completon {
    NSString *baseURL = @"https://api.cognitive.microsoft.com/sts/v1.0/issueToken";
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    request.URL = [NSURL URLWithString:baseURL];
    request.HTTPMethod = @"POST";
    [request setValue:kMicrosoftTranslatorTextAPIKey forHTTPHeaderField:@"Ocp-Apim-Subscription-Key"];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (completon) {
            completon(data, error);
        }
        NSString *token = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@", token);
    }];
    [task resume];
}

- (NSString *)queryStringWithDict:(NSDictionary *)dict {
    NSMutableString *query = [NSMutableString string];
    for (NSString *key in dict) {
        id value = dict[key];
        [query appendFormat:@"&%@=%@", key, value];
    }
    if (query.length > 1) {
        return [query substringFromIndex:1];
    }
    return [query copy];
}

- (void)translateText:(NSString *)text fromLanguage:(NSString *)from toLanguage:(NSString *)to {
    NSString *baseURL = @"https://api.microsofttranslator.com/V2/Http.svc/Translate";
    NSDictionary *parameters = @{
                                 @"text": text,
                                 @"from": from,
                                 @"to": to,
                                 @"contentType": @"text/html",
                                 };
    NSString *query = [self queryStringWithDict:parameters];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *url = [NSString stringWithFormat:@"%@?%@", baseURL, query];
    request.URL = [NSURL URLWithString:url];
//    request.HTTPMethod = @"POST";
    [request setValue:kMicrosoftTranslatorTextAPIKey forHTTPHeaderField:@"Ocp-Apim-Subscription-Key"];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *token = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@", token);
    }];
    [task resume];
}


@end
