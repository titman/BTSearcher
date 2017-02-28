//
//  SearchTextField.m
//  BTSearcher
//
//  Created by Guolicheng on 2017/2/28.
//  Copyright © 2017年 titman. All rights reserved.
//

#import "SearchTextField.h"

@implementation SearchTextField

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(void)mouseEntered:(NSEvent *)theEvent{
    
    CALayer *lay = [self layer];
    CGColorRef  myColor=CGColorCreateGenericRGB(0, 0, 1, 1);
    [lay setBorderColor:myColor];
    [lay setBorderWidth:4];
    //[self setWantsLayer:YES];
    [self setLayer:lay];
    [self makeBackingLayer];
    //CGColorRelease(myColor);
}

-(void)mouseExited:(NSEvent *)theEvent{
    
    CALayer *lay = [self layer];
    CGColorRef  myColor=CGColorCreateGenericRGB(0, 0, 1, 1);
    [lay setBorderColor:myColor];
    [lay setBorderWidth:0];
    //[self setWantsLayer:YES];
    [self setLayer:lay];
    [self makeBackingLayer];
    //CGColorRelease(myColor);
}



-(void)updateTrackingAreas{
    
    [super updateTrackingAreas];
//    if (trackingArea){
//        [self removeTrackingArea:trackingArea];
//    }
//    
//    NSTrackingAreaOptions options = NSTrackingInVisibleRect | NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow;
//    trackingArea = [[NSTrackingArea alloc] initWithRect:NSZeroRect options:options owner:self userInfo:nil];
//    [self addTrackingArea:trackingArea];
    
}

@end
