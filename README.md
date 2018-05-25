## WXDownloadImage

![image](https://github.com/supergithuber/WXDownloadManager/blob/master/example.gif)

1. 基于URLSession进行封装的下载组件，可以用来并行下载文件，取消文件单个文件下载，取消全部文件的下载
2. WXDownloadModel是对下载文件的抽象
3. 下载文件的相关接口都在WXDownloadManager.h文件中
4. 具体的使用Demo在ViewController.m中
5. 支持断点续传，程序退出后进入，依旧保持着刚才的下载状态
6. 支持设置最大同时下载数目maxDownloadNumber，多出来的任务会挂起，可以随时取消和删除
7. 源码中有遇到的所有坑和注意点，可以参考下
8. 可以实时更新文件下载的进度，百分比，文件名，文件大小，已经下载大小

其中比较重要的函数

``` objc

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
      
```

NSURLSessionDataDelegate

```objc

//收到Response之后就会调用，这里开启文件流，并可以获取文件总大小
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{

}

//在接收数据的过程中会调用这个函数，这里通过block回调各种接收过程中的变化
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{

}

```

NSURLSessionDelegate

```objc

//完成时调用，关闭流，移除model并回调完成状态
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{

}

```
下载的时候调用这个，在block中可以拿到下载的状态，下载文件的百分比，以及完成的情况，从而更新view，具体的block参数参考WXDownloadModel.h文件

## Usage 

### Carthage

add this to your cartfile

```
github "supergithuber/WXDownloadManager" == 0.5.0
```

### Manual

download project then Drag "WXDownLoadManager/DownManager" folder to your project

or

drag DownloadManager.framework to your project
