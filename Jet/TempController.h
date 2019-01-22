//
//  TempController.h
//  Jet
//
//  Created by 洪波 on 2019/1/21.
//  Copyright © 2019 洪波. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "JetResource.h"

NS_ASSUME_NONNULL_BEGIN

#define ColorHex(s)     [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1.0]
#define ScreenSize      [[UIScreen mainScreen] bounds].size
#define StatusHeight    [[UIApplication sharedApplication] statusBarFrame].size.height

@interface TempController : UIViewController

@property (nonatomic,strong) JetResource    *jetResource;
@property (nonatomic,readwrite) NSString    *pageUrl;
@property (nonatomic,strong) WKWebView      *webView;

- (void)loadPageContent;

@end

NS_ASSUME_NONNULL_END
