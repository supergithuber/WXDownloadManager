//
//  WXDownloadManager.m
//  WXDownLoadManager
//
//  Created by Wuxi on 17/3/1.
//  Copyright © 2017年 Wuxi. All rights reserved.
//


/**
 保存文件的根目录，建议用NSSearchPathForDirectoriesInDomains获取
 */
#define WXDownloadDirectory  [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] \
                               stringByAppendingPathComponent:NSStringFromClass([self class])]

/**
 保存文件总大小的plist文件路径
 {"fileName":totalLength}
 */
#define WXFilesTotalLengthPlistPath [WXDownloadDirectory stringByAppendingPathComponent:@"FilesTotalLength.plist"]

#import "WXDownloadManager.h"

@interface WXDownloadManager ()<NSURLSessionDelegate, NSURLSessionDataDelegate>

//["fileName":NSURLSessionDataTask]
@property (nonatomic, strong)NSMutableDictionary *dataTaskDictionary;
//["tastIdentifier":downloadModel]
@property (nonatomic, strong)NSMutableDictionary *downloadModelDictionary;

@end

@implementation WXDownloadManager

+(void)load
{
    [self createDownloadDirectory];
}

+ (instancetype)sharedManager
{
    static WXDownloadManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[WXDownloadManager alloc] init];
        
    });
    return manager;
}

#pragma mark helper
- (NSString *)fileNameForURL:(NSURL *)URL
{
    return [URL lastPathComponent];
}
- (NSString *)localFilePath:(NSURL *)URL
{
    NSString *fileName = [self fileNameForURL:URL];
    return [WXDownloadDirectory stringByAppendingPathComponent:fileName];
}
- (CGFloat)filePercentage:(NSURL *)URL
{
    if ([self totalLength:URL] == 0)
    {
        return 0.f;
    }
    if ([self isCompleted:URL])
    {
        return 1.f;
    }
    return 1.f * [self hasDownloadLength:URL] / [self totalLength:URL];
}
+ (void)createDownloadDirectory
{
    NSString *downloadDirectory = WXDownloadDirectory;
    BOOL isDirectory = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExist = [fileManager fileExistsAtPath:downloadDirectory isDirectory:&isDirectory];
    if (!isExist || !isDirectory)
    {
        [fileManager createDirectoryAtPath:downloadDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

#pragma mark - download
- (void)download:(NSURL *)URL
           state:(downloadStateBlock)state
      percentage:(downloadPercentageBlock)percentage
      completion:(downloadCompletionBlock)completion
{
    if (!URL)
    {
        return;
    }
    if ([self isCompleted:URL])
    {
        if (state)
        {
            state(WXDownloadStateCompleted);
        }
        return;
    }
    //切换状态
    if ([self dataTask:URL])
    {
        NSURLSessionDataTask *dataTask = [self dataTask:URL];
        if (dataTask.state == NSURLSessionTaskStateRunning)
        {
            [self pauseDownload:URL];
        }
        else
        {
            [self startDownload:URL];
        }
        return;
    }
    NSURLSession * session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                           delegate:self
                                                      delegateQueue:[[NSOperationQueue alloc] init]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    //表示要从哪个字节开始获取，后面的减号表示后面的所有字节，少了这个减号就不会下载了
    NSString *range = [NSString stringWithFormat:@"bytes=%lld-", [self hasDownloadLength:URL]];
    [request setValue:range forHTTPHeaderField:@"Range"];
    //获取task，才可以通过代理获取数据
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request];
    self.dataTaskDictionary[[self fileNameForURL:URL]] = dataTask;
    
    WXDownloadModel *downloadModel = [[WXDownloadModel alloc] init];
    downloadModel.fileURL = URL;
    downloadModel.outputStream = [NSOutputStream outputStreamToFileAtPath:[self localFilePath:URL] append:YES];
    downloadModel.stateBlock = state;
    downloadModel.percentageBlock = percentage;
    downloadModel.completionBlock = completion;
    //放入model字典
    NSUInteger identifier = arc4random() % 10000 + arc4random() % 10000;
        //readonly
    [dataTask setValue:@(identifier) forKeyPath:@"taskIdentifier"];
    self.downloadModelDictionary[@(dataTask.taskIdentifier).stringValue] = downloadModel;
    
    [self startDownload:URL];
    
}
- (void)startDownload:(NSURL *)URL
{
    NSURLSessionDataTask * dataTask = [self dataTask:URL];
    if (!dataTask)
    {
        return;
    }
    [dataTask resume];
    WXDownloadModel * downloadModel = [self downloadModel:dataTask];
    if (!downloadModel)
    {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (downloadModel.stateBlock)
        {
            downloadModel.stateBlock(WXDownloadStateDownloading);
        }
    });
}
- (void)pauseDownload:(NSURL *)URL
{
    NSURLSessionDataTask *dataTask = [self dataTask:URL];
    if (!dataTask)
    {
        return;
    }
    [dataTask suspend];
    WXDownloadModel *downloadModel = [self downloadModel:dataTask];
    if (!downloadModel)
    {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (downloadModel.stateBlock)
        {
            downloadModel.stateBlock(WXDownloadStateSuspended);
        }
    });
}
#pragma mark - NSURLSessionDelegate
//完成时调用，关闭流，移除model并回调完成状态
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    WXDownloadModel *downloadModel = [self downloadModel:(NSURLSessionDataTask *)task];
    if (!downloadModel)
    {
        return;
    }
    [downloadModel closeOutputStream];
    
    [self.dataTaskDictionary removeObjectForKey:[self fileNameForURL:downloadModel.fileURL]];
    [self.downloadModelDictionary removeObjectForKey:@(task.taskIdentifier).stringValue];
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self isCompleted:downloadModel.fileURL])
        {
            if (downloadModel.completionBlock)
            {
                downloadModel.completionBlock(YES, [self localFilePath:downloadModel.fileURL], error);
            }
            if (downloadModel.stateBlock)
            {
                downloadModel.stateBlock(WXDownloadStateCompleted);
            }
            return;
        }
        if (error)
        {
            if (downloadModel.completionBlock)
            {
                downloadModel.completionBlock(NO, nil, error);
            }
            if (downloadModel.stateBlock)
            {
                downloadModel.stateBlock(WXDownloadStateFailed);
            }
        }
    });
}
#pragma mark - NSURLSessionDataDelegate
//收到Response之后就会调用，这里开启文件流，并可以获取文件总大小
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    WXDownloadModel *downloadModel = [self downloadModel:dataTask];
    if (!downloadModel)
    {
        return;
    }
    //准备写文件
    [downloadModel.outputStream open];
    //文件总大小
    long long totalLength = response.expectedContentLength + [self hasDownloadLength:downloadModel.fileURL];
    downloadModel.totalLength = totalLength;
    NSMutableDictionary *totalLengthDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:WXFilesTotalLengthPlistPath] ?: [NSMutableDictionary dictionary];
    totalLengthDictionary[[self fileNameForURL:downloadModel.fileURL]] = @(totalLength);
    [totalLengthDictionary writeToFile:WXFilesTotalLengthPlistPath atomically:YES];
    
    //传这个才会继续调用下面的delegate函数，继续接收数据
    completionHandler(NSURLSessionResponseAllow);
    
}
//在接收数据的过程中会调用这个函数，这里通过block回调各种接收过程中的变化
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    WXDownloadModel *downloadModel = [self downloadModel:dataTask];
    if (!downloadModel)
    {
        return;
    }
    [downloadModel.outputStream write:data.bytes maxLength:data.length];
    dispatch_async(dispatch_get_main_queue(), ^{
        //在下载过程中，点击删除按钮，以下任务可能被提交，也可能没被提交给主线程
        //万一已经提交给主线程，导致会再调一遍下面的block，这样被重置为0的总size就不会变为0
        //加上downloadModel.outputStream.streamStatus != NSStreamStatusNotOpen可以防止这个问题
        //因为点击删除会close outputstream，这样就不会调用下面的block
        if (downloadModel.percentageBlock && downloadModel.outputStream.streamStatus != NSStreamStatusNotOpen)
        {
            long long receivedData =  [self hasDownloadLength:downloadModel.fileURL];
            long long totalData = downloadModel.totalLength;
            CGFloat percentage = 1.f * receivedData / totalData;
            downloadModel.percentageBlock (receivedData, totalData, percentage);
        }
    });
}
#pragma mark - getFromDictionary
- (NSURLSessionDataTask *)dataTask:(NSURL *)URL
{
    return self.dataTaskDictionary[[self fileNameForURL:URL]];
}
- (WXDownloadModel *)downloadModel:(NSURLSessionDataTask *)dataTask
{
    return self.downloadModelDictionary[@(dataTask.taskIdentifier).stringValue];
}
#pragma mark - queryDictionary
- (BOOL)isCompleted:(NSURL *)URL
{
    if ([self totalLength:URL] != 0)
    {
        if([self totalLength:URL] == [self hasDownloadLength:URL])
            return YES;
    }
    return NO;
}
- (long long)totalLength:(NSURL *)URL
{
    //从plist文件中获得，而不是从downloadModel中获得
    //保证下次程序重新启动的时候，可以获取文件的下载状态
    NSDictionary *fileLengthDictionary = [NSDictionary dictionaryWithContentsOfFile:WXFilesTotalLengthPlistPath];
    if (!fileLengthDictionary)
    {
        return 0;
    }
    if (!fileLengthDictionary[[self fileNameForURL:URL]])
    {
        return 0;
    }
    return [fileLengthDictionary[[self fileNameForURL:URL]] longLongValue];
}
- (long long)hasDownloadLength:(NSURL *)URL
{
    //从下载文件中获得
    NSDictionary *fileAttributeDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:[self localFilePath:URL] error:nil];
    return [fileAttributeDictionary[NSFileSize] longLongValue];
}
#pragma mark - delete
- (void)deleteFile:(NSURL *)URL
{
    NSURLSessionDataTask *dataTask = [self dataTask:URL];
    WXDownloadModel *downloadModel = [self downloadModel:dataTask];
    //remove from dic
    [downloadModel closeOutputStream];
    [self.downloadModelDictionary removeObjectForKey:@(dataTask.taskIdentifier).stringValue];
    //remove from dic
    [dataTask cancel];
    [self.dataTaskDictionary removeObjectForKey:[self fileNameForURL:URL]];
    
    //remove local file
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:[self localFilePath:URL]])
    {
        NSError *error;
        [fileManager removeItemAtPath:[self localFilePath:URL] error:&error];
        if (error)
        {
            NSLog(@"remove file error%@",error);
        }
    }
    //remove totalLength in dictionary
    NSMutableDictionary *totalDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:WXFilesTotalLengthPlistPath];
    //nothing when key doesn't exist
    [totalDictionary removeObjectForKey:[self fileNameForURL:URL]];
    [totalDictionary writeToFile:WXFilesTotalLengthPlistPath atomically:YES];
    
}
- (void)deleteAllFiles
{
    // close stream
    NSArray *downloadModelArray = self.downloadModelDictionary.allValues;
    for (WXDownloadModel *downloadModel in downloadModelArray)
    {
        [downloadModel performSelector:@selector(closeOutputStream)];
    }
    //cancel
    NSArray *dataTaskArray = self.dataTaskDictionary.allValues;
    for (NSURLSessionDataTask *dataTask in dataTaskArray)
    {
        [dataTask performSelector:@selector(cancel)];
    }
    //remove local file,including plist file
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *fileNames = [fileManager contentsOfDirectoryAtPath:WXDownloadDirectory error:nil];
    NSError *error;
    for (NSString * fileName in fileNames)
    {
        [fileManager removeItemAtPath:[WXDownloadDirectory stringByAppendingPathComponent:fileName] error:&error];
        if (error)
        {
            NSLog(@"remove all files error %@",error);
        }
    }
}
#pragma mark - getter
- (NSMutableDictionary *)dataTaskDictionary
{
    if (!_dataTaskDictionary)
    {
        _dataTaskDictionary = [NSMutableDictionary dictionary];
    }
    return _dataTaskDictionary;
}
- (NSMutableDictionary *)downloadModelDictionary
{
    if (!_downloadModelDictionary)
    {
        _downloadModelDictionary = [NSMutableDictionary dictionary];
    }
    return _downloadModelDictionary;
}
@end
