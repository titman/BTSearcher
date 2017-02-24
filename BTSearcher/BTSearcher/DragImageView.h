//
//  DragImageView.h
//  BTSearcher
//
//  Created by Guolicheng on 2017/2/24.
//  Copyright © 2017年 titman. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DragImageView : NSTextField

@property(nonatomic, weak) NSViewController * parentViewController;

-(void) hideNow;

@end
