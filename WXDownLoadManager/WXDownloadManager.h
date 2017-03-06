//
//  WXDownloadManager.h
//  WXDownLoadManager
//
//  Created by Wuxi on 17/3/1.
//  Copyright © 2017年 Wuxi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WXDownloadModel.h"

@interface WXDownloadManager : NSObject
//最大同时下载数目:默认1
@property (nonatomic, assign)NSInteger maxDownloadNumber;

+ (instancetype)sharedManager;

/**
 下载的时候调用这个

 @param URL 远程文件的URL
 @param state 下载状态回调
 @param percentage 下载百分比回调
 @param completion 下载完成回调
 */
- (void)download:(NSURL *)URL
           state:(downloadStateBlock)state
      percentage:(downloadPercentageBlock)percentage
      completion:(downloadCompletionBlock)completion;


/**
 文件下载百分比，程序启动的时候要从这里读取

 @param URL 远程文件的URL
 @return 文件下载的百分比
 */
- (CGFloat)filePercentage:(NSURL *)URL;


/**
 删除要下载的文件

 @param URL 远程文件的URL
 */
- (void)deleteFile:(NSURL *)URL;


/**
 取消所有文件的下载
 */
- (void)deleteAllFiles;


/**
 返回本地文件的名字

 @param URL 远程文件的URL
 @return 文件名
 */
- (NSString *)fileNameForURL:(NSURL *)URL;
@end
