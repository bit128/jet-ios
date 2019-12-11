//
//  JetResource.h
//  Jet
//
//  Created by 洪波 on 2019/1/21.
//  Copyright © 2019 洪波. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ONLINE_SYNC     NO
#define SERVER_HOST     @"http://192.168.1.2:8001/"
#define CONFIG_NAME     @"version.json"
#define DEFAULT_PAGE    @"app-page:home"
#define SYNC_LIST       @"sync_list"

@interface JetResource : NSObject

@property (nonatomic, readwrite) NSString *cachePath;
@property (nonatomic, strong) NSDictionary *localConfig;

+ (instancetype)share;
+ (instancetype)instance;

- (NSString *)loadPage: (NSString *)pageUrl;
- (NSString *)loadFile: (NSString *)fileName;

@end
