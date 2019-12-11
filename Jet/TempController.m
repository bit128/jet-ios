//
//  TempController.m
//  Jet
//
//  Created by 洪波 on 2019/1/21.
//  Copyright © 2019 洪波. All rights reserved.
//

#import "TempController.h"

@interface TempController ()<WKScriptMessageHandler,WKNavigationDelegate,WKUIDelegate>

@end

@implementation TempController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    //判断圆角屏
    float screenHeight = ScreenSize.height - StatusHeight;
    if (@available(iOS 11.0, *)) {
        screenHeight -= self.navigationController.view.safeAreaInsets.bottom;
    }
    //webview视图
    WKWebViewConfiguration *webViewConfig = [WKWebViewConfiguration new];
    webViewConfig.allowsInlineMediaPlayback = YES;
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, StatusHeight, ScreenSize.width, screenHeight)
                                      configuration:webViewConfig];
    [self.webView setNavigationDelegate:self];
    [self.webView setUIDelegate: self];
    [self.webView.scrollView setBounces: NO];
    [self.webView.scrollView setShowsVerticalScrollIndicator:NO];
    [self.view addSubview:self.webView];
    //加载页面内容
    self.jetResource = [JetResource share];
    if (self.pageUrl == nil) {
        self.pageUrl = DEFAULT_PAGE;
    }
    if ([self.pageUrl hasPrefix:DEFAULT_PAGE]) {
        //首页清空页面栈
        NSMutableArray *pageStack = [[NSMutableArray alloc] initWithArray:[self.navigationController viewControllers]];
        [pageStack removeObjectsInRange:NSMakeRange(0, pageStack.count-1)];
        [self.navigationController setViewControllers: pageStack];
    }
    //默认js桥接（目的让js可以检测出平台）
    [[self.webView configuration].userContentController addScriptMessageHandler:self name:@"initWebkit"];
    //加载页面内容
    [self loadPageContent];
}

- (void)loadPageContent {
    NSString *pageContent = [self.jetResource loadPage:self.pageUrl];
    if (pageContent != nil) {
        [self.webView loadHTMLString:pageContent baseURL:[NSURL fileURLWithPath:self.jetResource.cachePath]];
    }
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(nonnull WKNavigationAction *)navigationAction decisionHandler:(nonnull void (^)(WKNavigationActionPolicy))decisionHandler {
    NSString *path = [NSString stringWithFormat:@"%@", [navigationAction.request URL]];
    if (! [self.pageUrl isEqualToString:path]) {
        if ([path hasPrefix:@"app-page:"]) {
            if ([path isEqualToString:@"app-page:back"]) {
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                TempController *vc = [TempController new];
                vc.pageUrl = path;
                [self.navigationController pushViewController:vc animated:YES];
            }
            decisionHandler(WKNavigationActionPolicyCancel);
        } else {
            decisionHandler(WKNavigationActionPolicyAllow);
        }
    } else {
        decisionHandler(WKNavigationActionPolicyCancel);
    }
}

/**
 * 实现 js alert 弹窗
 */
-(void) webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

/**
 * 实现 js confirm 弹窗
 */
-(void) webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
