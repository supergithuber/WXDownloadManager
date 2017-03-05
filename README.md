## WXDownloadImage

![image](https://github.com/supergithuber/WXDownloadManager/blob/master/example.gif)

1. 基于URLSession进行封装的下载组件，可以用来并行下载文件，取消文件单个文件下载，取消全部文件的下载
2. WXDownloadModel是对下载文件的抽象
3. 下载文件的相关接口都在WXDownloadManager.h文件中
4. 具体的使用方式在ViewController.m中

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

下载的时候调用这个，在block中可以拿到下载的状态，下载文件的百分比，以及完成的情况，从而更新view，具体的block参数参考WXDownloadModel.h文件
