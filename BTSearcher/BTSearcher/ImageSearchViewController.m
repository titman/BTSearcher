//
//  ImageSearchViewController.m
//  BTSearcher
//
//  Created by Guolicheng on 2017/2/17.
//  Copyright © 2017年 titman. All rights reserved.
//

#import "ImageSearchViewController.h"
#import "AppDelegate.h"

@interface ImageSearchViewController () <WebFrameLoadDelegate, WebDownloadDelegate>

@end

@implementation ImageSearchViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = @"搜索结果";
    
    NSString * url = nil;
    
    if (IAMAGE_SEARCH_TYPE == 0) {
        
        url = [NSString stringWithFormat:@"http://image.baidu.com/n/pc_search?rn=10&appid=0&tag=1&isMobile=0&queryImageUrl=%@&querySign=&fromProduct=&productBackUrl=&fm=&uptype=plug_in", self.imageURL];
        
        self.webView.frameLoadDelegate = self;
        [self.webView.mainFrame loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];

    }
    else{
        
        url = [NSString stringWithFormat:@"https://www.google.com/searchbyimage?&image_url=%@", self.imageURL];
        
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
    }
}

- (void)webView:(WebView *)sender didFailProvisionalLoadWithError:(NSError *)error forFrame:(WebFrame *)frame
{
    NSLog(@"1");
}

- (void)webView:(WebView *)sender didFailLoadWithError:(NSError *)error forFrame:(WebFrame *)frame
{
    NSLog(@"2");
}

@end
