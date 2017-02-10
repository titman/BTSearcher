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

#import "HTMLParser.h"
#import "TFHpple.h"
#import "ViewController.h"
#import "AppDelegate.h"

@implementation HTMLParser


+(NSMutableArray *) parsingWithObject:(id)object
{
    if (SOURCE_TYPE == SourceTypeBTURLs) {
        
        return [HTMLParser bturls:object];
    }
    else if(SOURCE_TYPE == SourceTypeBTKIKI){
        
        return [HTMLParser btkiki:object];
    }
    
    return nil;
}

+(NSString *) parsingMagnetWithObject:(id)object
{
    if (SOURCE_TYPE == SourceTypeBTURLs) {
        
        return [HTMLParser bturlsMagnet:object];
    }
    else if(SOURCE_TYPE == SourceTypeBTKIKI){
        
        return [HTMLParser btkikiMagnet:object];
    }
    
    return nil;
}

+(NSMutableArray *) bturls:(id)object
{
    NSMutableArray * result = [NSMutableArray array];
    
    
    TFHpple * hpple = [[TFHpple alloc] initWithHTMLData:object];

    NSArray * mlistElements = [hpple searchWithXPathQuery:@"//ul[@class = 'mlist']"];

    for (TFHppleElement * mlistElement in mlistElements) {

        NSArray * liElements = [mlistElement searchWithXPathQuery:@"//li"];

        for (TFHppleElement * liElement in liElements) {

            BTItem * item = [[BTItem alloc] init];
            
            NSArray * h3Elements = [liElement searchWithXPathQuery:@"//h3[@class = 'T1']"];
            
            for (TFHppleElement * h3Element in h3Elements) {

                NSArray * aElements = [h3Element searchWithXPathQuery:@"//a"];
                
                for (TFHppleElement * aElement in aElements) {

                    item.title = [aElement.text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                    item.href = [NSString stringWithFormat:@"http://www.bturls.net%@", [aElement objectForKey:@"href"]];
                }
            }
        
            NSArray * itemListElements = [liElement searchWithXPathQuery:@"//div[@class = 'item-list']"];
            
            NSMutableArray * files = [NSMutableArray array];
            
            for (TFHppleElement * itemListElement in itemListElements) {
                
                [files addObject:itemListElement.text];
            }
            
            item.files = files;
            
            
            NSArray * dtElements = [liElement searchWithXPathQuery:@"//dt"];

            for (TFHppleElement * dtElement in dtElements) {

                NSArray * spanElements = [dtElement searchWithXPathQuery:@"//span"];
                
                int i = 0;
                
                for (TFHppleElement * spanElement in spanElements) {

                    if(i == 0) item.date = spanElement.text;
                    if(i == 1) item.size = spanElement.text;
                    if(i == 2) item.fileCount = spanElement.text;

                    i++;
                }
            }
            
            [result addObject:item];
        }
    }
    
    return result;
}

+(NSString *) bturlsMagnet:(id)object
{
    TFHpple * hpple = [[TFHpple alloc] initWithHTMLData:object];
    
    NSArray * resultElements = [hpple searchWithXPathQuery:@"//dl[@class = 'BotInfo']"];
    
    for (TFHppleElement * resultElement in resultElements) {

        NSArray * aElements = [resultElement searchWithXPathQuery:@"//a"];

        for (TFHppleElement * aElement in aElements) {
         
            return [aElement objectForKey:@"href"];
        }

    }
    
    return nil;
}

+(NSMutableArray *) btkiki:(id)object
{
    NSMutableArray * result = [NSMutableArray array];
    
    
    TFHpple * hpple = [[TFHpple alloc] initWithHTMLData:object];
    
    NSArray * resultElements = [hpple searchWithXPathQuery:@"//div[@id = 'result']"];
    
    for (TFHppleElement * resultElement in resultElements) {
        
        NSArray * gElements = [resultElement searchWithXPathQuery:@"//div[@class = 'g']"];
        
        for (TFHppleElement * gElement in gElements) {
            
            BTItem * item = [[BTItem alloc] init];
            
            NSArray * aElements = [gElement searchWithXPathQuery:@"//a"];
            
            for (TFHppleElement * aElement in aElements) {
                
                item.title = [aElement objectForKey:@"title"];
                item.href = [aElement objectForKey:@"href"];
            }
            
            NSArray * stdElements = [gElement searchWithXPathQuery:@"//div[@class = 'std']"];
            
            for (TFHppleElement * stdElement in stdElements) {
                
                NSMutableArray * multipleFiles = [[NSMutableArray alloc] init];
                
                
                NSArray * multipleFilesElements = [stdElement searchWithXPathQuery:@"//div[@class = 'list']"];
                
                for (TFHppleElement * multipleFilesElement in multipleFilesElements) {
                    
                    [multipleFiles addObject:multipleFilesElement.text];
                }
                
                item.files = multipleFiles;
            }
            
            
            NSArray * std2Elements = [gElement searchWithXPathQuery:@"//div[@class = 'std2']"];
            
            
            for (TFHppleElement * std2Element in std2Elements) {
                
                NSArray * spanElements = [std2Element searchWithXPathQuery:@"//span"];
                
                NSInteger i = 0;
                
                for (TFHppleElement * spanElement in spanElements) {
                    
                    if (i == 0) item.size = spanElement.text;
                    else if (i == 1) item.fileCount = spanElement.text;
                    else if (i == 2) item.date = spanElement.text;
                    
                    i++;
                }
                
            }
            
            
            [result addObject:item];
        }
    }
    
    return result;
}

+(NSString *) btkikiMagnet:(id)object
{
    TFHpple * hpple = [[TFHpple alloc] initWithHTMLData:object];
    
    NSArray * resultElements = [hpple searchWithXPathQuery:@"//div[@id = 'result']"];
    
    for (TFHppleElement * resultElement in resultElements) {
        
        NSArray * aElements = [resultElement searchWithXPathQuery:@"//a"];
        
        for (TFHppleElement * aElement in aElements) {
            
            return aElement.text;
            break;
        }
    }
    
    return nil;
}

@end
