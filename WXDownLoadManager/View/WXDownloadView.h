//
//  WXDownloadView.h
//  WXDownLoadManager
//
//  Created by Wuxi on 17/3/2.
//  Copyright © 2017年 Wuxi. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^downloadBlock)();
typedef void(^deleteBlock)();

@interface WXDownloadView : UIView

@property (nonatomic, copy)NSString *startButtonText;

@property (nonatomic, copy)NSString *currentSizeText;
@property (nonatomic, assign)CGFloat percentage;
@property (nonatomic, copy)NSString *totalSizeText;

@property (nonatomic, copy)NSString *percentageText;

@property (nonatomic, copy)NSString *deleteText;

@property (nonatomic, copy)NSString *fileName;

@property (nonatomic, copy)downloadBlock downloadBlock;
@property (nonatomic, copy)deleteBlock deleteBlock;

+ (instancetype)downloadView;

- (void)resetAllViews;
@end
