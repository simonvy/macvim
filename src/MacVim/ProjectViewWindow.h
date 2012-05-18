//
//  ProjectViewWindow.h
//  MacVim
//
//  Created by Qian Tao on 2/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ProjectViewWindow : NSWindowController <NSTableViewDataSource, NSTextDelegate> {
}

+ (id) sharedInstance;
- (void) loadFilesInDirectory: (NSURL *)directory;
- (void) show;

@end
