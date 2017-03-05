//
//  WXDownloadModel.h
//  WXDownLoadManager
//
//  Created by Wuxi on 17/3/1.
//  Copyright © 2017年 Wuxi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, WXDownloadState)
{
    WXDownloadStateDownloading = 0,
    WXDownloadStateSuspended,
    WXDownloadStateCompleted,
    WXDownloadStateFailed
};

//回调文件下载状态
typedef void(^downloadStateBlock)(WXDownloadState state);
//回调文件下载百分比，来更新view
typedef void(^downloadPercentageBlock)(long long receivedSize, long long expectedSize, CGFloat receivedPercentage);
//回调文件下载完成情况
typedef void(^downloadCompletionBlock)(BOOL isSucess, NSString *filePath, NSError *error);


@interface WXDownloadModel : NSObject

//文件的下载流
@property (nonatomic, strong)NSOutputStream *outputStream;

//远程文件的URL
@property (nonatomic, strong)NSURL *fileURL;

//文件的总长度
@property (nonatomic, assign)long long totalLength;

@property (nonatomic, copy) downloadStateBlock stateBlock;
@property (nonatomic, copy) downloadPercentageBlock percentageBlock;
@property (nonatomic, copy) downloadCompletionBlock completionBlock;

- (void)closeOutputStream;

@end
