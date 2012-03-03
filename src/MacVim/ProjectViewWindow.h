//
//  ProjectViewWindow.h
//  MacVim
//
//  Created by Qian Tao on 2/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ProjectViewWindow : NSWindowController <NSTableViewDataSource, NSTextDelegate> {
    NSArray *files;
    NSArray *filteredFiles;
}


@property (assign) IBOutlet NSTableView *table;
@property (assign) IBOutlet NSSearchField *filterTextField;

+ (id) sharedInstance;
- (void) loadFilesInDirectory: (NSURL *)directory;
- (IBAction)filterChanged: (id)sender;
- (IBAction)fileSelected:(id)sender;
- (void) show;

@end
