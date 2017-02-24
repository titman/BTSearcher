//
//  MagnetTableView.m
//  BTSearcher
//
//  Created by Guolicheng on 2017/2/16.
//  Copyright © 2017年 titman. All rights reserved.
//

#import "MagnetTableView.h"

@implementation MagnetTableView

-(void) awakeFromNib
{
    [self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
}

-(NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender{
    NSPasteboard *pboard = [sender draggingPasteboard];
    
    if ([[pboard types] containsObject:NSFilenamesPboardType]) {
        return NSDragOperationCopy;
    }
    
    return NSDragOperationNone;
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender
{
    return NSDragOperationNone;
}

//- (void)draggingExited:(nullable id <NSDraggingInfo>)sender
//{
//
//}
//
//- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
//{
//    return YES;
//}
//- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
//{
//    return YES;
//}
//
//- (void)concludeDragOperation:(nullable id <NSDraggingInfo>)sender
//{
//    
//}
///* draggingEnded: is implemented as of Mac OS 10.5 */
//- (void)draggingEnded:(nullable id <NSDraggingInfo>)sender
//{
//
//}
//
///* the receiver of -wantsPeriodicDraggingUpdates should return NO if it does not require periodic -draggingUpdated messages (eg. not autoscrolling or otherwise dependent on draggingUpdated: sent while mouse is stationary) */
//- (BOOL)wantsPeriodicDraggingUpdates
//{
//    return YES;
//}

@end
