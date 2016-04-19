# facebookLoginDemo
facebook第三方登录的demo
## 注意
### 1.下载下来工程的话，自己需要添加那几个framework，工程才能运行。
### 2.考虑到网络问题，我也打了一个zip的包,里面是facebook的framework，在工程根目录下，解压后再拖到工程里进行使用
### 3.因为目前这个应用并没有通过facebook的审核，所以只有我自己的账号能登录进去，你需要将所有涉及到appID、appKey、appSecret的地方的值改成你自己注册的才行

>Demo地址： https://github.com/chenhuaizhe/facebookLoginDemo

## 前期工作

- 科学上网
- 拥有一个facebook账号
- 注册成为[facebook开发者](https://developers.facebook.com/)

## 网站配置

- 创建应用


![](http://upload-images.jianshu.io/upload_images/530099-85eccd1c165704bf.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
![](https://cdn-images-1.medium.com/max/800/1*o9ru8EYmjJ6k1Y11zVf9eg.png)
![](https://cdn-images-1.medium.com/max/800/1*GKh_hnH8xEGUCKdtkfsPQA.png)
![](https://cdn-images-1.medium.com/max/800/1*wqqj43klsnvCb7rGSEYYLQ.png)

- 下载sdk

![](https://cdn-images-1.medium.com/max/800/1*sMguPMdAU_atwdx55Fo82A.png)

- 在Facebook应用页输入自己的工程的唯一标识符，bundle identifier
![](https://cdn-images-1.medium.com/max/800/1*fcXQRo7VNpcpeQj1i466GA.png)

## 工程配置

- 找到下载的sdk，并把sdk中的 **FBSDKCoreKit.Framework, FBSDKLoginKit.Framework, FBSDKShareKit.Framework **添加到xcode工程中
![](https://cdn-images-1.medium.com/max/800/1*bx9AsrEK20S23ljgMToo3Q.png)

- 修改Info.plist文件配置

![](https://cdn-images-1.medium.com/max/800/1*EwH-RsXCdgu8gyfbFcGbbw.png)

添加以下键值对，里面的键值对每个应用都是不一样的，注意在facebook创建的应用集成页生成自己的应用后，再复制到自己的工程中
```xml
<key>CFBundleURLTypes</key>
 <array>
   <dict>
   <key>CFBundleURLSchemes</key>
   <array>
     <string>fb749973445139192</string>
   </array>
   </dict>
 </array>
 <key>FacebookAppID</key>
 <string>749973445139192</string>
 <key>FacebookDisplayName</key>
 <string>fabdemo</string>
```

为了适配iOS9，还需要添加添加以下：
```xml
 <key>LSApplicationQueriesSchemes</key>
 <array>
   <string>fbapi</string>
   <string>fb-messenger-api</string>
   <string>fbauth2</string>
   <string>fbshareextension</string>
 </array>
```
- 配置** AppDelegate.m**中的代码

头文件
```objective-c
 #import <FBSDKCoreKit/FBSDKCoreKit.h>
```
方法实现
```objective-c
 - (void)applicationDidBecomeActive:(UIApplication *)application {
   [FBSDKAppEvents activateApp];
 }
 
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
   [[FBSDKApplicationDelegate sharedInstance] application:application
                            didFinishLaunchingWithOptions:launchOptions];
   return YES;
 }
 
 - (BOOL)application:(UIApplication *)application
             openURL:(NSURL *)url
   sourceApplication:(NSString *)sourceApplication
          annotation:(id)annotation {
   return [[FBSDKApplicationDelegate sharedInstance]     application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
 }
```

## 检测是否接入成功
在你的**ViewController.m **中，添加facebook的按钮，试验一下看是否能跳转和登录。

头文件
```objective-c
  #import <FBSDKCoreKit/FBSDKCoreKit.h>
 #import <FBSDKLoginKit/FBSDKLoginKit.h>
```
Facebook的button

```objective-c
 FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
 loginButton.center = self.view.center;
 [self.view addSubview:loginButton];
```

如果这时候程序崩溃，尝试一下以下方法
- 检查一下你的Info.plist文件是否正确，设置完后clean一下工程
- 自己设置appID 
![](https://cdn-images-1.medium.com/max/800/1*PG3iczDI-Kvfb8nUf1QnNA.png)
- 自己手动配置url schemes 
![](https://cdn-images-1.medium.com/max/800/1*03rFMx6om9uwhB9n1SshHA.png)

## 自定义button
自定义一个button，给button加入以下点击事件

```objective-c
//自定义login button的点击事件
 - (IBAction)loginBtnClicked:(id)sender {
     FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
     [login
      logInWithReadPermissions: @[@"public_profile"]
      fromViewController:self
      handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
          NSLog(@"facebook login result.grantedPermissions = %@,error = %@",result.grantedPermissions,error);
          if (error) {
              NSLog(@"Process error");
          } else if (result.isCancelled) {
              NSLog(@"Cancelled");
          } else {
              NSLog(@"Logged in");
          }
      }];
 }
```
 
这样，根据登录成功与失败的结果，我们就能做一些操作了。

### 登录成功我们可以通过 FBSDKProfile 这个类来访问到 用户信息
我们可以注册一个通知，来监听 userProfile是否改变，如果改变，就把它显示在页面的label上

```objective-c
 [[NSNotificationCenter defaultCenter] addObserver:self
                                              selector:@selector(_updateContent:)
                                                  name:FBSDKProfileDidChangeNotification
                                                object:nil];
```
实现通知事件

```objective-c
- (void)_updateContent:(NSNotification *)notification {
     self.infoLabel.text = [NSString stringWithFormat:@"name = %@,userID = %@",[FBSDKProfile currentProfile].name,[FBSDKProfile currentProfile].userID];
 }
```

另外，为了保证profile能自动跟随access token的更新而更新，在**AppDelegate.m**中还要添加

![](https://cdn-images-1.medium.com/max/800/1*w-K_t_ANgmnADAlKRVTtMQ.png)

```objective-c
[FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
```

## Tips
- 应用没有通过facebook审核的时候，只能通过你在facebook创建app的账号来进行第三方登录


