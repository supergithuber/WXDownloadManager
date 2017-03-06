//
//  WXDownloadView.m
//  WXDownLoadManager
//
//  Created by Wuxi on 17/3/2.
//  Copyright © 2017年 Wuxi. All rights reserved.
//

#import "WXDownloadView.h"

@interface WXDownloadView ()

@property (weak, nonatomic) IBOutlet UIButton *startButton;

@property (weak, nonatomic) IBOutlet UILabel *currentSizeLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *totalSizeLabel;

@property (weak, nonatomic) IBOutlet UILabel *percentageLabel;

@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation WXDownloadView

+ (instancetype)downloadView
{
    NSBundle *bundle=[NSBundle mainBundle];
    NSArray *objs=[bundle loadNibNamed:@"WXDownloadView" owner:nil options:nil];
    return [objs lastObject];
}

- (IBAction)downloadFile:(id)sender {
    if(self.downloadBlock)
    {
        self.downloadBlock();
    }
}

- (IBAction)deleteFile:(id)sender {
    if (self.deleteBlock)
    {
        self.deleteBlock();
    }
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        
    }
    return self;
}
- (void)awakeFromNib
{
    [super awakeFromNib];
}
- (void)layoutSubviews
{
    [super layoutSubviews];
}
- (void)resetAllViews
{
    self.percentage = 0;
    self.currentSizeText = @"0";
    self.totalSizeText = @"0";
    self.percentageText = @"0%";
    self.startButtonText = @"开始";
}
#pragma mark setter and getter
- (void)setStartButtonText:(NSString *)startButtonText
{
    [self.startButton setTitle:startButtonText forState:UIControlStateNormal];
}
- (NSString *)startButtonText
{
    return self.startButton.titleLabel.text;
}

- (void)setCurrentSizeText:(NSString *)currentSizeText
{
    self.currentSizeLabel.text = currentSizeText;
}
- (NSString *)currentSizeText
{
    return self.currentSizeLabel.text;
}

- (void)setPercentage:(CGFloat)percentage
{
    self.progressView.progress = percentage;
}
- (CGFloat)percentage
{
    return self.progressView.progress;
}

- (void)setTotalSizeText:(NSString *)totalSizeText
{
    self.totalSizeLabel.text = totalSizeText;
}
- (NSString *)totalSizeText
{
    return self.totalSizeLabel.text;
}

- (void)setPercentageText:(NSString *)percentageText
{
    self.percentageLabel.text = percentageText;
}
- (NSString *)setPercentageText
{
    return self.percentageLabel.text;
}

- (void)setDeleteText:(NSString *)deleteText
{
    [self.deleteButton setTitle:deleteText forState:UIControlStateNormal];
}
- (NSString *)deleteText
{
    return self.deleteButton.titleLabel.text;
}

- (NSString *)fileName
{
    return self.nameLabel.text;
}
- (void)setFileName:(NSString *)fileName
{
    self.nameLabel.text = fileName;
}
@end
