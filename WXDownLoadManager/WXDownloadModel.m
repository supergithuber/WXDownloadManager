//
//  WXDownloadModel.m
//  WXDownLoadManager
//
//  Created by Wuxi on 17/3/1.
//  Copyright © 2017年 Wuxi. All rights reserved.
//

#import "WXDownloadModel.h"

@implementation WXDownloadModel

- (void)closeOutputStream
{
    if (_outputStream)
    {
        [_outputStream close];
        _outputStream = nil;
    }
}
@end
