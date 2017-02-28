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
