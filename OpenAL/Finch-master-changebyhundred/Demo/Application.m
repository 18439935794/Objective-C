//  作者:香蕉大大  简书地址：http://www.jianshu.com/users/a3ae6d7c68b6/latest_articles
//  微博:http://weibo.com/u/6013257513?is_all=1
//  QQ技术讨论交流群 : 365204530
//  微信个人技术公众号：大大家的IOS说（一起用碎片时间学习最新最有用的IOS资料）
//  微信个人账号：hundreda


#import "Application.h"
#import "Controller.h"
#import "FISoundEngine.h"



@interface Application ()
@property(strong) FISoundEngine *soundEngine;
@end

@implementation Application
@synthesize window;

#pragma mark Initialization

- (void) applicationDidFinishLaunching: (UIApplication*) application
{
    _soundEngine = [FISoundEngine sharedEngine];
    [_controller setSound:[_soundEngine soundNamed:@"finch.wav" maxPolyphony:4 error:NULL]];

    [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(handleAudioSessionInterruption:)
        name:AVAudioSessionInterruptionNotification
        object:[AVAudioSession sharedInstance]];

    [window setRootViewController:_controller];
    [window makeKeyAndVisible];
}

#pragma mark Interruption Handling

- (void) handleAudioSessionInterruption: (NSNotification*) event
{
    NSUInteger type = [[[event userInfo] objectForKey:AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
    switch (type) {
        case AVAudioSessionInterruptionTypeBegan:
            NSLog(@"Audio interruption began, suspending sound engine.");
            [_soundEngine setSuspended:YES];
            break;
        case AVAudioSessionInterruptionTypeEnded:
            if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
                NSLog(@"Audio interruption ended, resuming sound engine.");
                [_soundEngine setSuspended:NO];
            } else {
                // Have to wait for the app to become active, otherwise
                // the audio session won’t resume correctly.
            }
            break;
    }
}

- (void) applicationDidBecomeActive: (UIApplication*) application
{
    if ([_soundEngine isSuspended]) {
        NSLog(@"Audio interruption ended while inactive, resuming sound engine now.");
        [_soundEngine setSuspended:NO];
    }
}

@end
