#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#include "GeneratedPluginRegistrant.h"
#import "CryptLib.h"
#import <Flutter/Flutter.h>
#import "NSData+Base64.h"
#import <Photos/Photos.h>

@implementation AppDelegate
- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
  FlutterViewController* controller = (FlutterViewController*)self.window.rootViewController;

  FlutterMethodChannel* batteryChannel = [FlutterMethodChannel
                                          methodChannelWithName:@"samples.flutter.io/battery"
                                          binaryMessenger:controller];
    __weak typeof(self) weakSelf = self;
[batteryChannel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {

    if ([@"getBatteryLevel" isEqualToString:call.method]) {
    NSString *sasToken = call.arguments[@"sasToken"];
    NSString *imagePath = call.arguments[@"imagePath"];
    NSString *uploadPath = call.arguments[@"uploadPath"];
    NSString *strExt = [[NSURL URLWithString:imagePath] pathExtension];
    NSLog(@"extension %@",strExt);

    NSString *strImageName = [NSString stringWithFormat:@"iosImage%@",[self randomStringWithLength:5]];

    NSString *strurl= [NSString stringWithFormat:@"%@%@.%@?%@",uploadPath,strImageName,strExt,sasToken];

    NSLog(@"img server url%@",strurl);

    NSURLSession *session = [NSURLSession sharedSession];

    NSURL *url = [NSURL URLWithString:strurl];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: url];
    //request.httpMethod = "PUT";
    [request setHTTPMethod:@"PUT"];
    [request setValue:@"img" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Accept"];
    [request setValue:@"BlockBlob" forHTTPHeaderField:@"x-ms-blob-type"];
        NSData *data =[NSData dataWithContentsOfFile:imagePath];
    [request setHTTPBody:data];

      NSLog(@"img server running");
  // [session dataTaskWithRequest:request];

    NSURLSessionUploadTask *uploadTask =  [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(error)
        {
            NSLog(@"Something went wrong");
             result(@"false");
        }
        if(response)
        {
            NSLog(@"response:");
             result([NSString stringWithFormat:@"%@.%@",strImageName,strExt]);
        }

    }];
    [uploadTask resume];



    }else     if ([@"encryption" isEqualToString:call.method]) {
        NSString *password = call.arguments[@"password"];
       NSString *str =  [self imgUploadingCode:password];
        result(str);    }
}];


  [GeneratedPluginRegistrant registerWithRegistry:self];

    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        switch (status) {
            case PHAuthorizationStatusAuthorized:
                NSLog(@"PHAuthorizationStatusAuthorized");
                break;
            case PHAuthorizationStatusDenied:
                NSLog(@"PHAuthorizationStatusDenied");
                break;
            case PHAuthorizationStatusNotDetermined:
                NSLog(@"PHAuthorizationStatusNotDetermined");
                break;
            case PHAuthorizationStatusRestricted:
                NSLog(@"PHAuthorizationStatusRestricted");
                break;
        }
    }];

  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}
-(NSString*)randomStringWithLength:(NSUInteger)length
{
    NSMutableString* random = [NSMutableString stringWithCapacity:length];

    for (NSUInteger i=0; i<length; i++)
    {
        char c = '0' + (unichar)arc4random()%36;
        if(c > '9') c += ('a'-'9'-1);
        [random appendFormat:@"%c", c];
    }

    return random;
}
-(NSString*)imgUploadingCode:(NSString*)strPwd
{
    StringEncryption *obj = [[StringEncryption alloc] init];
    NSString *plainText = strPwd;
    NSString *key =[obj sha256:@"sd5b75nb7577#^%$%*&G#CGF*&%@#%*&" length:32];

   NSString *iv = @"F@$%^*GD$*(*#!12";


   NSData *encryptPassword = [obj encrypt:[plainText dataUsingEncoding:NSASCIIStringEncoding] key:key iv:iv];
   //print the encrypted text
   // NSString *strEncy = [[NSString alloc] initWithData:encryptPassword encoding:NSASCIIStringEncoding] ;
    NSString *strEncy = [encryptPassword base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];

    NSLog(@"encrypted password %@ ",strEncy);

    return strEncy;
 }



@end
