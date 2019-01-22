//
//  JetVersion.m
//  Jet
//
//  Created by 洪波 on 2019/1/22.
//  Copyright © 2019 洪波. All rights reserved.
//

#import "JetVersion.h"
#import <SystemConfiguration/SCNetworkReachability.h>

@implementation JetVersion

+ (instancetype)instance {
    JetVersion *jetVersion = [JetVersion new];
    jetVersion.jetResource = [JetResource share];
    return jetVersion;
}

- (BOOL)hasNetwork {
    //创建ip地址 0.0.0.0
    struct sockaddr_storage zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.ss_len = sizeof(zeroAddress);
    zeroAddress.ss_family = AF_INET;
    
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkConnectionFlags flags;
    //获取连接标志
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    //如果没有获得标志，则说明没有联网
    if (! didRetrieveFlags) {
        return NO;
    }
    //根据连接标志判断网络状态
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    return (isReachable && !needsConnection) ? YES : NO;
}

/**
 * 同步线上版本
 */
- (void)syncVersion {
    if ([self hasNetwork]) {
        NSURL *url = [NSURL URLWithString:[SERVER_HOST stringByAppendingString:@"getConfig"]];
        //发起网络请求
        NSURLSession *urlSession = [NSURLSession sharedSession];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
        NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (data != nil) {
                BOOL hasChange = NO;
                NSDictionary *onlineConfig = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                NSDictionary *syncList = [onlineConfig objectForKey:SYNC_LIST];
                if (self.jetResource.localConfig != nil) {
                    NSDictionary *localList = [self.jetResource.localConfig objectForKey:SYNC_LIST];
                    for (NSString *key in [syncList allKeys]) {
                        int newVersion = [[syncList objectForKey:key] intValue];
                        int oldVersion = [[localList objectForKey:key] intValue];
                        if (newVersion > oldVersion) {
                            hasChange = YES;
                            [self syncFile:key];
                        }
                    }
                } else {
                    for (NSString *key in [syncList allKeys]) {
                        [self syncFile:key];
                    }
                    hasChange = YES;
                }
                if (hasChange) {
                    [data writeToFile:[self.jetResource.cachePath stringByAppendingString:CONFIG_NAME] atomically:YES];
                }
                self.jetResource.localConfig = onlineConfig;
            }
        }];
        [dataTask resume];
    } else {
        NSLog(@"----> no network.");
    }
}

/**
 * 同步线上文件
 */
- (void)syncFile: (NSString *)fileName {
    NSURLSession *urlSession = [NSURLSession sharedSession];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@getFile/%@", SERVER_HOST, fileName]]];
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data != nil) {
            [data writeToFile:[self.jetResource.cachePath stringByAppendingString:fileName] atomically:YES];
            NSLog(@"----> 更新线上文件：%@", fileName);
        }
    }];
    [dataTask resume];
}

@end
