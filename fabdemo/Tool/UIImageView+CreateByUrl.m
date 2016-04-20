
#import "UIImageView+CreateByUrl.h"

@implementation UIImageView (CreateByUrl)
-(void)setImageByUrl:(NSString *)urlString
{
    __block UIImageView *weakSelf = self;//在block内部使用的变量
    //创建一个子线程来做数据请求
    dispatch_queue_t downloadQueue = dispatch_queue_create("download", NULL);
    //在线程队列里面创建一个子线程
    dispatch_async(downloadQueue, ^{
        //数据请求
        NSURL *url = [NSURL URLWithString:urlString];
        //同步请求
        NSError *error;
      NSData *data = [NSData dataWithContentsOfURL:url options:NSDataReadingMapped error:&error];
        NSLog(@"%@",error);
        //用请求回来的data创建一个uiimage
        UIImage *image = [UIImage imageWithData:data];
        //回到主线程更新UI
        dispatch_sync(dispatch_get_main_queue(), ^{
            //主线程内部，可以更新UI了
            weakSelf.image = image;
        });
    
    });
}
@end
