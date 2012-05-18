//
//  ProjectViewWindow.m
//  MacVim
//
//  Created by Qian Tao on 2/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProjectViewWindow.h"
#import "MMAppController.h"

@interface ProjectViewWindow ()


@property (assign) IBOutlet NSTableView *table;
@property (assign) IBOutlet NSSearchField *filterTextField;

@property (retain) NSArray *files;
@property (retain) NSArray *filteredFiles;

- (void) showFilesWithFilter: (NSString *)filter;
- (void) filter: (id)sender;

@end

@implementation ProjectViewWindow

@synthesize files = _files;
@synthesize filteredFiles = _filteredFiles;
@synthesize table = _table;
@synthesize filterTextField = _filterTextField;

+(id) sharedInstance {
    static ProjectViewWindow *singleton = nil;
    
    if (!singleton) {
        singleton = [[ProjectViewWindow alloc] initWithWindowNibName:@"ProjectView"];
        [singleton setWindowFrameAutosaveName:@"Find Files"];
    }
    
    return singleton;
}

- (void) show {
    [self.filterTextField setStringValue: @""];
    [self showFilesWithFilter: @""];
    [self.table deselectRow: [self.table selectedRow]];
    NSWindow *window = [self window];
    [window makeFirstResponder: self.filterTextField];
    [window makeKeyAndOrderFront: self];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    if (aTableView == self.table) {
        if (self.filteredFiles) {
            return [self.filteredFiles count];
        }
    }
    return 0;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    if (aTableView == self.table) {
        NSURL *fileURL = [self.filteredFiles objectAtIndex: rowIndex];
        NSString *localizedName = nil;
		[fileURL getResourceValue: &localizedName forKey: NSURLLocalizedNameKey error: nil];
        NSTextFieldCell *cell = [[[NSTextFieldCell alloc] initTextCell: localizedName] autorelease];
        return cell;
    }
    return nil;
}

- (void) loadFilesInDirectory: (NSURL *)directory {
    NSMutableArray *files = [NSMutableArray array];
    
    NSFileManager *fileManager = [NSFileManager new];
    NSDirectoryEnumerator *e = [fileManager enumeratorAtURL:directory includingPropertiesForKeys:[NSArray arrayWithObjects:NSURLLocalizedNameKey, NSURLIsDirectoryKey, nil]
                                                    options:NSDirectoryEnumerationSkipsHiddenFiles errorHandler:nil];
    
    for (NSURL *fileURL in e) {
        NSNumber *isDirectory = nil;
		[fileURL getResourceValue: &isDirectory forKey: NSURLIsDirectoryKey error: nil];
		if ([isDirectory boolValue] == NO) {
            [files addObject: fileURL];
		}
    }
    
    self.files = files;
    
    [fileManager release];
    [self showFilesWithFilter: @""];
}

- (void) showFilesWithFilter: (NSString *)filter {
    NSMutableArray *fc = [NSMutableArray array];
    
    if (self.files) {
        for (NSURL *fileURL in self.files) {
            NSString *localizedName = nil;
            [fileURL getResourceValue: &localizedName forKey: NSURLLocalizedNameKey error: nil];
            
            bool searched = YES;
            if ([filter length]) {
                NSRange search = [localizedName rangeOfString: filter options: NSCaseInsensitiveSearch];
                searched = !(search.location == NSNotFound);
            }
            
            if (searched) {
                [fc addObject: fileURL];
            }
        }
    }
    
    self.filteredFiles = fc;
    
    [self.table reloadData];
}

- (IBAction)filterChanged:(id)sender {
    [NSRunLoop cancelPreviousPerformRequestsWithTarget: self];
    [self performSelector: @selector(filter:) withObject: sender afterDelay: 0.8];
}

- (IBAction)fileSelected:(id)sender {
    NSTableView *tv = (NSTableView *)sender;
    NSInteger index = [tv selectedRow];
    if (index >= 0) {
        NSURL *file = [self.filteredFiles objectAtIndex: index];
        [[MMAppController sharedInstance] openFiles: [NSArray arrayWithObject: [file path]]
                                      withArguments: [NSDictionary dictionary]];
    }
}

- (void) filter: (id) sender {
    NSSearchField *filterField = (NSSearchField *)sender;
    [self showFilesWithFilter: [filterField stringValue]];
}

@end


