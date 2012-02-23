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

- (void) showFilesWithFilter: (NSString *)filter;
+ (NSArray *) loadFilesInDirectory: (NSURL *)directory withDepth: (NSInteger) depth;
- (void) filter: (id)sender;

@end

@implementation ProjectViewWindow

@synthesize table;
@synthesize filterTextField;

+(id) sharedInstance {
    static ProjectViewWindow *singleton = nil;
    
    if (!singleton) {
        singleton = [[ProjectViewWindow alloc] initWithWindowNibName:@"ProjectView"];
        [singleton setWindowFrameAutosaveName:@"Find Files"];
    }
    
    return singleton;
}

- (void) show {
    [filterTextField setStringValue: @""];
    [self showFilesWithFilter: @""];
    [table deselectRow: [table selectedRow]];
    NSWindow *window = [self window];
    [window makeFirstResponder: self.filterTextField];
    [window makeKeyAndOrderFront: self];
}

- (id)initWithWindow:(NSWindow *)window {
    self = [super initWithWindow:window];
    if (self) {
        files = nil;
        filteredFiles = nil;
    }
    return self;
}

- (void)dealloc {
    if (files) {
        [files release]; files = nil;
    }
    if (filteredFiles) {
        [filteredFiles release]; filteredFiles = nil;
    }
    [super dealloc];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    if (aTableView == table) {
        if (filteredFiles) {
            return [filteredFiles count];
        }
    }
    return 0;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    if (aTableView == table) {
        NSURL *fileURL = [filteredFiles objectAtIndex: rowIndex];
        NSString *localizedName = nil;
		[fileURL getResourceValue: &localizedName forKey: NSURLLocalizedNameKey error: nil];
        NSTextFieldCell *cell = [[[NSTextFieldCell alloc] initTextCell: localizedName] autorelease];
        return cell;
    }
    return nil;
}

- (void) loadFilesInCurrentDirectory {
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *cd = [fm currentDirectoryPath];
	NSURL *url = [NSURL URLWithString: cd];
    
    if (files) {
		[files release];
		files = nil;
	}
    
    files = [[ProjectViewWindow loadFilesInDirectory: url withDepth:10] retain];
    [self showFilesWithFilter: @""];
}

- (void) showFilesWithFilter: (NSString *)filter {
	if (files == nil) {
		return;
	}
    if (filteredFiles) {
        [filteredFiles release];
        filteredFiles = nil;
    }
    
    NSMutableArray *fc = [[NSMutableArray alloc] initWithCapacity: [files count]];
    for (NSURL *fileURL in files) {
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
    filteredFiles = [fc retain];
    
    [table reloadData];
}

- (IBAction)filterChanged:(id)sender {
    [NSRunLoop cancelPreviousPerformRequestsWithTarget: self];
    [self performSelector: @selector(filter:) withObject: sender afterDelay: 0.8];
}

- (IBAction)fileSelected:(id)sender {
    NSTableView *tv = (NSTableView *)sender;
    NSInteger index = [tv selectedRow];
    if (index >= 0) {
        NSURL *file = [filteredFiles objectAtIndex: index];
        [[MMAppController sharedInstance] openFiles: [NSArray arrayWithObject: [file path]]
                                      withArguments: [NSDictionary dictionary]];
    }
}

- (void) filter: (id) sender {
    NSSearchField *filterField = (NSSearchField *)sender;
    [self showFilesWithFilter: [filterField stringValue]];
}

+ (NSArray *) loadFilesInDirectory: (NSURL *)directory withDepth: (NSInteger) depth {
    
    NSError *err = nil;
	NSArray *properties = [NSArray arrayWithObjects: NSURLLocalizedNameKey, NSURLIsDirectoryKey, NSURLContentModificationDateKey, nil];
	NSArray *fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtURL: directory includingPropertiesForKeys: properties options: NSDirectoryEnumerationSkipsHiddenFiles error: &err];
	if (err) {
		// something is wrong have to handle it
		return [NSArray array];
	}
    
    NSMutableArray *fc = [[[NSMutableArray alloc] initWithCapacity: [fileList count]] autorelease];
    for (NSURL *fileURL in fileList) {
		NSNumber *isDirectory = nil;
		[fileURL getResourceValue: &isDirectory forKey: NSURLIsDirectoryKey error: nil];
		if ([isDirectory boolValue]) {
            if (depth >= 0) {
                NSArray *items = [self loadFilesInDirectory: fileURL withDepth: (depth - 1)];
                [fc addObjectsFromArray: items]; 
            }
		} else {
            [fc addObject: fileURL];
        }
    }
    
    return fc;
}

@end


