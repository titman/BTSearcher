//
//
//      _|          _|_|_|
//      _|        _|
//      _|        _|
//      _|        _|
//      _|_|_|_|    _|_|_|
//
//
//  Copyright (c) 2014-2015, Licheng Guo. ( http://nsobject.me )
//  http://github.com/titman
//
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
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
