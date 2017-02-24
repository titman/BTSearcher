//
//  ImageSearchViewController.h
//  BTSearcher
//
//  Created by Guolicheng on 2017/2/17.
//  Copyright © 2017年 titman. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface ImageSearchViewController : NSViewController

@property(nonatomic, strong) IBOutlet WebView * webView;

@property(nonatomic, strong) NSString * imageURL;

@end
