//
//  ViewController.m
//  WXDownLoadManager
//
//  Created by Wuxi on 17/2/28.
//  Copyright © 2017年 Wuxi. All rights reserved.
//

#import "ViewController.h"
#import "WXDownloadView.h"
#import "WXDownloadManager.h"

NSString * const downloadURLString1 = @"http://baobab.wdjcdn.com/14564977406580.mp4";
NSString * const downloadURLString2 = @"http://baobab.wdjcdn.com/1442142801331138639111.mp4";


#define kDownloadURL1 [NSURL URLWithString:downloadURLString1]
#define kDownloadURL2 [NSURL URLWithString:downloadURLString2]

#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;

@interface ViewController ()

@property (nonatomic, strong)WXDownloadView *view1;
@property (nonatomic, strong)WXDownloadView *view2;
@end

@implementation ViewController

- (void)viewDidLoad {
    WS(ws);
    [super viewDidLoad];
    _view1 = [WXDownloadView downloadView];
    _view1.frame = CGRectMake(10, 100, 300, 200);
    _view1.downloadBlock = ^(){
        [ws downloadView:ws.view1 downloadFile:kDownloadURL1];
    };
    _view1.deleteBlock = ^(){
        [ws downloadView:ws.view1 deleteFile:kDownloadURL1];
    };
    [self.view addSubview:_view1];
    
    _view2 = [WXDownloadView downloadView];
    _view2.frame = CGRectMake(10, 300, 300, 200);
    _view2.downloadBlock = ^(){
        [ws downloadView:ws.view2 downloadFile:kDownloadURL2];
    };
    _view2.deleteBlock = ^(){
        [ws downloadView:ws.view2 deleteFile:kDownloadURL2];
    };
    [self.view addSubview:_view2];
    
    [self updateView:_view1 forURL:kDownloadURL1];
    [self updateView:_view2 forURL:kDownloadURL2];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateView:(WXDownloadView *)view forURL:(NSURL *)URL
{
    CGFloat percentage =  [[WXDownloadManager sharedManager] filePercentage:URL];
    view.percentage = percentage;
    view.percentageText = [NSString stringWithFormat:@"%.f%%", percentage * 100];
    view.startButtonText = [self titleWithPercentage:percentage];
    view.currentSizeText = @"0";
    view.totalSizeText = @"0";
    view.fileName = [[WXDownloadManager sharedManager] fileNameForURL:URL];
    
}

#pragma mark block function
- (void)downloadView:(WXDownloadView *)downloadView downloadFile:(NSURL *)URL
{
    [[WXDownloadManager sharedManager] download:URL state:^(WXDownloadState state) {
        
        downloadView.startButtonText = [self titleWithDownloadState:state];
        
    } percentage:^(long long receivedSize, long long expectedSize, CGFloat receivedPercentage) {
        
        downloadView.currentSizeText = [NSString stringWithFormat:@"%zdMB", receivedSize / 1024 / 1024];
        downloadView.totalSizeText = [NSString stringWithFormat:@"%zdMB", expectedSize / 1024 / 1024];
        downloadView.percentageText = [NSString stringWithFormat:@"%.f%%", receivedPercentage * 100];
        downloadView.percentage = receivedPercentage;
        
    } completion:^(BOOL isSucess, NSString *filePath, NSError *error) {
        
        if (isSucess) {
            NSLog(@"filePath: %@", filePath);
        } else {
            NSLog(@"error: %@", error);
        }
        
    }];
}
- (void)downloadView:(WXDownloadView *)downloadView deleteFile:(NSURL *)URL
{
    [[WXDownloadManager sharedManager]deleteFile:URL];
    
    [downloadView resetAllViews];
}
#pragma mark deleteAll
- (IBAction)deleteAll:(id)sender {
    [[WXDownloadManager sharedManager]deleteAllFiles];
    
    [_view1 resetAllViews];
    [_view2 resetAllViews];
    
}

#pragma mark helper
- (NSString *)titleWithDownloadState:(WXDownloadState)state {
    
    switch (state) {
        case WXDownloadStateDownloading:
            return @"暂停";
        case WXDownloadStateSuspended:
            return @"继续";
        case WXDownloadStateCompleted:
            return @"结束";
        case WXDownloadStateFailed:
            return @"开始";
    }
}
- (WXDownloadState)stateWithPercentage:(CGFloat)percentage {
    
    WXDownloadState state;
    if (percentage == 1.0) {
        state = WXDownloadStateCompleted;
    } else if (percentage > 0) {
        state = WXDownloadStateSuspended;
    } else {
        state = WXDownloadStateFailed;
    }
    return state;
}

- (NSString *)titleWithPercentage:(CGFloat)percentage {
    
    WXDownloadState state;
    if (percentage == 1.0) {
        state = WXDownloadStateCompleted;
    } else if (percentage > 0) {
        state = WXDownloadStateSuspended;
    } else {
        state = WXDownloadStateFailed;
    }
    return [self titleWithDownloadState:state];
}
@end
