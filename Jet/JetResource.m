//
//  JetResource.m
//  Jet
//
//  Created by 洪波 on 2019/1/21.
//  Copyright © 2019 洪波. All rights reserved.
//

#import "JetResource.h"

@implementation JetResource

/**
 * 单利构造
 */
+ (instancetype)share {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self instance];
    });
    return instance;
}

/**
 * 自定义构造方法
 */
+ (instancetype)instance {
    JetResource *jetResource = [JetResource new];
    jetResource.cachePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingString:@"/"];
    if (ONLINE_SYNC) {
        //加载本地配置文件
        NSString *configFile = [jetResource.cachePath stringByAppendingString:CONFIG_NAME];
        if ([[NSFileManager defaultManager] fileExistsAtPath:configFile]) {
            NSString *configFileData = [[NSString alloc] initWithContentsOfFile:configFile encoding:NSUTF8StringEncoding error:nil];
            jetResource.localConfig = [NSJSONSerialization JSONObjectWithData:[configFileData dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        }
    }
    return jetResource;
}

/**
 * 加载页面
 */
- (NSString *)loadPage: (NSString *)pageUrl {
    NSRange pageNameRange = [pageUrl rangeOfString:@"app-page:"];
    if (pageNameRange.length > 0) {
        NSString *pageFile = [pageUrl substringFromIndex:pageNameRange.location+9];
        NSURL *pageFileUrl = [NSURL URLWithString:pageFile];
        //NSString *params = [pageFileUrl query];
        NSString *content = [self loadFile:[[pageFileUrl path] stringByAppendingString:@".html"]];
        //匹配资源文件
        NSString *regexString = @"<asset>([\\w\\-\\.]*?)<\\/asset>";\
        NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:regexString options:NSRegularExpressionCaseInsensitive error:nil];
        NSMutableArray *matchs = [[NSMutableArray alloc] initWithCapacity:5];
        [regular enumerateMatchesInString:content options:NSMatchingReportCompletion range:NSMakeRange(0, content.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
            [matchs addObject:[content substringWithRange:result.range]];
        }];
        for (NSString *m in matchs) {
            if (m.length > 0) {
                NSString *assetFile = [m substringWithRange:NSMakeRange(7, m.length-15)];
                NSString *extName = [assetFile pathExtension];
                if ([extName isEqualToString:@"css"]) {
                    content = [content stringByReplacingOccurrencesOfString:m withString:[NSString stringWithFormat:@"<style type=\"text/css\">%@</style>", [self loadFile:assetFile]]];
                } else if ([extName isEqualToString:@"js"]) {
                    content = [content stringByReplacingOccurrencesOfString:m withString:[NSString stringWithFormat:@"<script type=\"text/javascript\">%@</script>", [self loadFile:assetFile]]];
                }
            }
        }
        content = [content stringByReplacingOccurrencesOfString:@"app-local:" withString:
                   [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/Temps/image/"]];
        return content;
    }
    return nil;
}

/**
 * 加载文件
 */
- (NSString *)loadFile: (NSString *)fileName {
    NSString *content = nil;
    NSString *filePath = [self.cachePath stringByAppendingString:fileName];
    if (ONLINE_SYNC && [[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        content = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    } else {
        NSString *localFile = [NSString stringWithFormat:@"%@/Temps/%@", [[NSBundle mainBundle] resourcePath], fileName];
        if ([[NSFileManager defaultManager] fileExistsAtPath:localFile]) {
            content = [[NSString alloc] initWithContentsOfFile:localFile encoding:NSUTF8StringEncoding error:nil];
        } else {
            NSLog(@"----> Local file not found.");
        }
    }
    return content;
}

@end
