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

#import "ViewController.h"
#import "AFNetworking.h"
#import "TFHpple.h"
#import "DJProgressHUD.h"
#import "ItemCell.h"
#import "HTMLParser.h"
#import "AppDelegate.h"
#import "ImageSearchViewController.h"
#import "JPEngine.h"

@implementation BTItem @end

@interface ViewController () <NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate, WebFrameLoadDelegate, WebResourceLoadDelegate>

@property(nonatomic, strong) NSMutableArray * datasource;
@property(nonatomic, strong) NSStatusItem * statusItem;

@property(nonatomic, strong) NSEvent * enterMonitor;
@property(nonatomic, strong) NSEvent * mouseMonitor;
@property(nonatomic, strong) NSEvent * localMonitor;

@property(nonatomic, strong) NSString * currentSourceName;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"JSLoadFinished" object:nil];
    
    
    self.statusItem        = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem.title  = @"";
    self.statusItem.image  = [NSImage imageNamed:@"BTSearcherIcon"];
    self.statusItem.target = self;
    self.statusItem.action = @selector(openWindow:);
    
    
    self.view.layer.backgroundColor = [[NSColor lightGrayColor] colorWithAlphaComponent:0.3].CGColor;
    self.preferredContentSize = NSMakeSize(self.view.frame.size.width, self.view.frame.size.height);
    
    self.tableView.delegate   = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight  = 110;
    
    self.enterMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskKeyDown handler:^NSEvent * (NSEvent * event){
        
        NSWindow * targetWindow = event.window;
        
        if (targetWindow != self.view.window) return event;
        
        if ([event keyCode] == 36) {
            
            [self loadData];
        }
        
        return event;
    }];
    
    
    self.mouseMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:NSEventMaskLeftMouseDragged | NSEventMaskLeftMouseUp handler:^(NSEvent * _Nonnull event) {
        
        if (event.type == NSEventTypeLeftMouseDragged) {
            
            self.dragImageView.hidden = NO;
            self.tip.hidden = YES;
        }
        else if(event.type == NSEventTypeLeftMouseUp){
            
            self.dragImageView.hidden = YES;
            self.tip.hidden = NO;
        }
    }];
    
    self.mouseMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskLeftMouseDragged | NSEventMaskLeftMouseUp handler:^(NSEvent * _Nonnull event) {
        
        if (event.type == NSEventTypeLeftMouseDragged) {
            
            self.dragImageView.hidden = NO;
            self.tip.hidden = YES;
        }
        else if(event.type == NSEventTypeLeftMouseUp){
            
            self.dragImageView.hidden = YES;
            self.tip.hidden = NO;
        }
        
        return event;
    }];
    
    self.dragImageView.parentViewController = self;
    
    
    [self performSelector:@selector(loadJS) withObject:nil afterDelay:0.1];
}

#pragma mark - JS Update

-(void) loadJS
{
    [DJProgressHUD showStatus:@"检查更新..." FromView:self.view];

    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    manager.responseSerializer     = [AFHTTPResponseSerializer serializer];
    
    NSString * url = @"http://titm.me/btsearcher/source.js";
    
    [manager GET:url parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        
        NSDictionary * dic = [ViewController dictionaryWithContentsOfData:responseObject];
        
        SEARCH_SOURCE = dic[@"source"];

        
        // 本地调试
//        NSString * path = [[NSBundle mainBundle] pathForResource:@"BTSearcher" ofType:@"js"];
//        NSString * js = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
//        [JPEngine evaluateScript:js];
//        [DJProgressHUD dismiss];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"JSLoadFinished" object:nil];
//        return;

        
        NSInteger appVersion = [[[NSUserDefaults standardUserDefaults] objectForKey:@"SourceVersion"] integerValue];
        NSInteger version    = [dic[@"version"] integerValue];
        
        if (appVersion < version) {
            
            // 全量更新
            [self loadParserJSFromDisk:NO version:version];
        }
        else{
            
            // 本地读取
            [self loadParserJSFromDisk:YES version:version];
        }
        
        [DJProgressHUD dismiss];
        
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        
        [DJProgressHUD dismiss];
    }];
    
}

-(void) loadParserJSFromDisk:(BOOL)yesOrNo version:(NSInteger)version
{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString * writePath =  [[paths objectAtIndex:0] stringByAppendingFormat:@"/Caches/BTSearcher.js"];
    
    if (yesOrNo) {
        
        NSString * js = [[NSString alloc] initWithContentsOfFile:writePath encoding:NSUTF8StringEncoding error:nil];
        
        if (!js.length) {
            
            [self loadParserJSFromDisk:NO version:version];
            return;
        }
        
        [JPEngine evaluateScript:js];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"JSLoadFinished" object:nil];
    }
    else{
        
        [DJProgressHUD showStatus:@"正在更新脚本..." FromView:self.view];

        AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
        manager.responseSerializer     = [AFHTTPResponseSerializer serializer];
        
        NSString * url = @"http://titm.me/btsearcher/BTSearcher.js";
        
        
        [manager GET:url parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
            
            NSString * js = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            
            // 写入本地
            [js writeToFile:writePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            
            // 注入JS
            [JPEngine evaluateScript:js];
            
            // 通知更新完成
            [[NSNotificationCenter defaultCenter] postNotificationName:@"JSLoadFinished" object:nil];
            
            // 存储版本号
            [[NSUserDefaults standardUserDefaults] setObject:@(version) forKey:@"SourceVersion"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            
            [DJProgressHUD dismiss];
            
        } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
            
            [DJProgressHUD dismiss];
        }];
    }
}

#pragma mark - Status Item

-(void)handleNotification:(NSNotification *)notification
{
    NSMenu * menu = [[NSMenu alloc] init];
    [menu addItemWithTitle:@"切换搜索源" action:nil keyEquivalent:@""];
    [menu addItem:[NSMenuItem separatorItem]];
    
    for (NSInteger i = 0; i < SEARCH_SOURCE.count; i++) {
        
        NSString * string = SEARCH_SOURCE[i];
        string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        NSArray * source = [string componentsSeparatedByString:@"|"];
        
        NSString * sourceName = source[0];
        
        [menu addItemWithTitle:sourceName action:@selector(changeSource:) keyEquivalent:@(i + 1).description];
    }
    
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItemWithTitle:@"切换图片搜索源" action:nil keyEquivalent:@""];
    [menu addItem:[NSMenuItem separatorItem]];
    
    [menu addItemWithTitle:@"百度图片搜索(默认)" action:@selector(changeImageSearchSource:) keyEquivalent:@"00"];
    [menu addItemWithTitle:@"Google图片搜索(需翻墙)" action:@selector(changeImageSearchSource:) keyEquivalent:@"01"];
    [menu addItem:[NSMenuItem separatorItem]];
    
    NSMenuItem * item = [menu addItemWithTitle:@"显示窗口(control+v)" action:@selector(openWindow:) keyEquivalent:@"01"];
    [item setKeyEquivalentModifierMask:NSControlKeyMask];
    [item setKeyEquivalent:@"v"];
    
    [menu addItem:[NSMenuItem separatorItem]];
    
    [menu addItemWithTitle:@"Quit BTSearcher" action:@selector(terminate:) keyEquivalent:@""];
    self.statusItem.menu = menu;
}

- (void)openWindow:(id)sender
{
    NSWindow * window = [self.view window]; // Get the window to open
    [window makeKeyAndOrderFront:nil];
}

-(void) changeSource:(NSMenuItem *)item
{
    SOURCE_TYPE = item.keyEquivalent.intValue - 1;
}

-(void) changeImageSearchSource:(NSMenuItem *)item
{
    IAMAGE_SEARCH_TYPE = item.keyEquivalent.intValue;
}

#pragma mark - Netwoking

-(void) loadData
{
    [DJProgressHUD showStatus:@"加载中..." FromView:self.view];
    
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    manager.responseSerializer     = [AFHTTPResponseSerializer serializer];
    
    NSString * string = SEARCH_SOURCE[SOURCE_TYPE];
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSArray * source = [string componentsSeparatedByString:@"|"];
    
    NSString * sourceName = source[0];
    NSString * sourceURL = source[1];
    
    sourceURL = [sourceURL stringByReplacingOccurrencesOfString:@"%@" withString:[self.textField.stringValue stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [manager GET:sourceURL parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        
        NSMutableArray * result = [HTMLParser parsingWithObject:responseObject sourceName:sourceName];
        
        self.datasource = result;
        [self.tableView reloadData];
        
        [DJProgressHUD dismiss];
        
        self.currentSourceName = sourceName;
        
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        
        [DJProgressHUD dismiss];
    }];
}

-(void) getMagnetWithURL:(NSString *)href
{
    [DJProgressHUD showStatus:@"获取磁力链..." FromView:self.view];
    
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    manager.responseSerializer     = [AFHTTPResponseSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"%@", href] parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        
        NSString * magnet = [HTMLParser parsingMagnetWithObject:responseObject sourceName:self.currentSourceName];
        
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:magnet]];
        
        [DJProgressHUD dismiss];
        
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        
        [DJProgressHUD dismiss];
        
    }];
}

#pragma mark - TableView

-(void)awakeFromNib
{
    [self.tableView registerNib:[[NSNib alloc] initWithNibNamed:@"ItemCell" bundle:nil] forIdentifier:@"cell"];
}

-(NSInteger) numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.datasource.count;
}

- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{
    ItemCell * cell = [tableView makeViewWithIdentifier:@"cell" owner:nil];
    
    BTItem * item = self.datasource[row];
    
    cell.title.stringValue = [NSString stringWithFormat:@"%@", item.title];
    cell.file1.stringValue = item.files.count ? item.files.firstObject : @"";
    cell.file2.stringValue = item.files.count >= 2 ? item.files[1] : @"......";
    cell.size.stringValue  = item.size;
    cell.count.stringValue = item.fileCount;
    cell.date.stringValue  = item.date;
    
    return cell;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    BTItem * item = self.datasource[row];
    
    if (item.magnet) {
        
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:item.magnet]];
    }
    else{
        
        [self getMagnetWithURL:item.href];
    }
    
    return NO;
}

#pragma mark - Others

+ (NSDictionary *)dictionaryWithContentsOfData:(NSData *)data {
    
    CFPropertyListRef list = CFPropertyListCreateFromXMLData(kCFAllocatorDefault, (__bridge CFDataRef)data, kCFPropertyListImmutable, NULL);
    
    if(list == nil) return nil;
    
    if ([(__bridge id)list isKindOfClass:[NSDictionary class]]) {
        
        return (__bridge NSDictionary *)list;
    }
    else {
        
        CFRelease(list);
        return nil;
    }
}



@end


