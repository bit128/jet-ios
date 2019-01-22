//
//  ViewController.m
//  Jet
//
//  Created by 洪波 on 2019/1/21.
//  Copyright © 2019 洪波. All rights reserved.
//

#import "ViewController.h"
#import "TempController.h"
#import "JetResource.h"
#import "JetVersion.h"

@interface ViewController ()

@property (nonatomic,strong) NSTimer *jumpTimer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 80, 200, 50)];
    [label setText:@"Hello,Jet."];
    [self.view addSubview:label];
    //同步页面
    if (ONLINE_SYNC) {
        [[JetVersion instance] syncVersion];
    }
    
    //2s后跳转到主页
    self.jumpTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(redirectPage) userInfo:nil repeats:NO];
}

- (void)redirectPage {
    TempController *vc = [TempController new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.jumpTimer invalidate];
    self.jumpTimer = nil;
}

@end
