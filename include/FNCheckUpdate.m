//
//  FNCheckUpdate.m
//  libFNUtilsDemo
//
//  Created by YijingNiu on 13-10-16.
//  Copyright (c) 2013年 YijingNiu. All rights reserved.
//

#define kAPPURL     @"http://itunes.apple.com/lookup?id="
#define kAPPName    [infoDict objectForKey:@"CFBundleDisplayName"]

#import "FNCheckUpdate.h"
@interface FNCheckUpdate () {
    NSString *_updateURL;
    NSMutableData *_jsonData;
}

@end

@implementation FNCheckUpdate
@synthesize delegate;
/*
 获取单例对象
 */
+ (FNCheckUpdate *)shareInstance {
    static FNCheckUpdate *update = nil;
    if (!update) {
        update = [[FNCheckUpdate alloc] init];
    }
    return update;
}

/*
 外部调用checkUpdateWithAppID方法来检测是否有更新版本
 appID是一串纯数字的编号 例如：656505553
 */
- (void)checkUpdateWithAppID:(NSString*)appID {
	NSString *urlStr = [NSString stringWithFormat:@"%@%@",kAPPURL, appID];
	NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:url
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                          timeoutInterval:30];
    // create the connection with the request
    // and start loading the data
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (theConnection) {
        [theConnection start];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (self.forceUpdate == YES) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_updateURL]];
    }
	else if (buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_updateURL]];
    }
}

#pragma nsurlconnectiondelegate
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"%@",@"***Get new version information failed***");
    if ([self.delegate respondsToSelector:@selector(hasNewVersion:)]) {
        [self.delegate hasNewVersion:NO];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _jsonData=[[NSMutableData alloc] init];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSDictionary *infoDict   = [[NSBundle mainBundle]infoDictionary];
    NSString *currentVersion = [infoDict objectForKey:@"CFBundleVersion"];
    NSError *error;
    NSDictionary *jsonData  = [NSJSONSerialization JSONObjectWithData:_jsonData options:kNilOptions error:&error];
    NSArray *infoArray  = [jsonData objectForKey:@"results"];
    
	if (infoArray.count >= 1) {
		NSDictionary *releaseInfo   = [infoArray objectAtIndex:0];
		NSString     *latestVersion = [releaseInfo objectForKey:@"version"];
		NSString     *releaseNotes  = [releaseInfo objectForKey:@"releaseNotes"];
		NSString     *title         = [NSString stringWithFormat:@"%@%@版本", kAPPName, latestVersion];
		_updateURL = [[releaseInfo objectForKey:@"trackViewUrl"] retain];
		if ([latestVersion compare:currentVersion] == NSOrderedDescending) {
			if (self.forceUpdate == YES) {
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:releaseNotes delegate:self cancelButtonTitle:nil otherButtonTitles:@"去App Store下载", nil];
				[alertView show];
			}
			else {
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:releaseNotes delegate:self cancelButtonTitle:@"忽略" otherButtonTitles:@"去App Store下载", nil];
				[alertView show];
			}
			
			if ([self.delegate respondsToSelector:@selector(hasNewVersion:)]) {
				[self.delegate hasNewVersion:YES];
			}
		}
		else {
			if ([self.delegate respondsToSelector:@selector(hasNewVersion:)]) {
				[self.delegate hasNewVersion:NO];
			}
		}
	}
	else if ([self.delegate respondsToSelector:@selector(hasNewVersion:)]) {
		[self.delegate hasNewVersion:NO];
	}
    _jsonData=nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_jsonData appendData:data];
}

@end
