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

@implementation BTItem @end

@interface ViewController () <NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate>

@property(nonatomic, strong) NSMutableArray * datasource;
@property(nonatomic, strong) NSEvent * enterMonitor;
@property(nonatomic, strong) NSStatusItem * statusItem;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.statusItem        = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem.title  = @"";
    self.statusItem.image  = [NSImage imageNamed:@"StatusItemIcon"];
    self.statusItem.target = self;
    self.statusItem.action = @selector(openWindow:);

    
    NSMenu * menu = [[NSMenu alloc] init];
    [menu addItemWithTitle:@"切换源" action:nil keyEquivalent:@""];
    [menu addItemWithTitle:@"BT磁力链(bturls.com)" action:@selector(changeSource:) keyEquivalent:@"1"];
    [menu addItemWithTitle:@"BTKIKI(btkiki.com)" action:@selector(changeSource:) keyEquivalent:@"2"];
    [menu addItemWithTitle:@"Quit BTSearcher" action:@selector(terminate:) keyEquivalent:@""];
    self.statusItem.menu = menu;
    

    
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
}

- (void)openWindow:(id)sender
{
    NSWindow * window = [self.view window]; // Get the window to open
    [window makeKeyAndOrderFront:nil];
}

-(void) changeSource:(NSMenuItem *)item
{
    SOURCE_TYPE = item.keyEquivalent.intValue;
}

-(void) loadData
{
    [DJProgressHUD showStatus:@"loading..." FromView:self.view];
    
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    manager.responseSerializer     = [AFHTTPResponseSerializer serializer];
    
    NSString * url = nil;
    
    if (SOURCE_TYPE == SourceTypeBTURLs) {
        
        url = [NSString stringWithFormat:@"http://www.bturls.net/search/%@_ctime_1.html", [self.textField.stringValue stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    else{
        
        url = [NSString stringWithFormat:@"http://www.btkiki.com/s/%@.html", [self.textField.stringValue stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
        
    [manager GET:url parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        
        NSMutableArray * result = [HTMLParser parsingWithObject:responseObject];
        
        self.datasource = result;
        [self.tableView reloadData];
        
        [DJProgressHUD dismiss];
        
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        
        [DJProgressHUD dismiss];
    }];
}

-(void) getMagnetWithURL:(NSString *)href
{
    [DJProgressHUD showStatus:@"Getting Magnet..." FromView:self.view];
    
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    manager.responseSerializer     = [AFHTTPResponseSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"%@", href] parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        
        NSString * magnet = [HTMLParser parsingMagnetWithObject:responseObject];
        
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:magnet]];
        
        [DJProgressHUD dismiss];
        
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        
        [DJProgressHUD dismiss];
        
    }];
}

#pragma mark -

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

    if(SOURCE_TYPE == SourceTypeBTURLs) cell.fileCountTip.stringValue = @"热  度：";
    else cell.fileCountTip.stringValue = @"文件数：";
    
    return cell;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    BTItem * item = self.datasource[row];

    [self getMagnetWithURL:item.href];
    
    return NO;
}


@end
