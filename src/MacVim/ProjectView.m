
#import "ProjectView.h"


- (id) initWithFrame: (NSRect)frame {
	id self = [super initWithFrame: frame];
	if (self) {
		files = nil;
		// setup the filter textfield and the files list view.
		fileList = [[NSMatrix alloc] initWithFrame: self.bounds mode: NSListModeMatrix cellClass: [NSTextFieldCell class] numberOfRows: 0 numberOfColumns: 1];
		NSTextField *filterField = [NSTextField new]; // field frame is not intialized

		[self addSubview: filterField];
		[self addSubview: fileList];
		
		NSDictionary *dict = NSDictionaryOfVariableBindings(filterField, fileList);
		[self addConstraints: [NSLayoutConstraint: constraitWithVisualFormat: @"H:|-[filterField]-|" options: 0 metrics: nil views: dict]];
		[self addConstraints: [NSLayoutConstraint: constraitWithVisualFormat: @"V:|-[filterField(20)]-[fileList]-|" options: 0 metrics: nil views: dict]];

		[filterField setDelegate: self];
		
		[filterField release];
	}
	return self;
}

- (void) dealloc {
	if (fileList) {
		[fileList release]; fileList = nil;
	}
	if (files) {
		[files release]; files = nil;
	}
	[super dealloc];
}

- (void) loadFilesInCurrentDirectory {
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *cd = [fm currentDirectoryPath];
	NSURL *url = [NSURL URLWithString: cd];
	[self loadFilesInDirectory: url];
}

- (void) loadFilesInDirectory: (NSURL *)path {
	if (files) {
		[files release];
		files = nil;
	}

	NSError *err = nil;
	NSArray *properties = [NSArray arrayWithObjects: NSURLLocalizedNameKey, NSURLIsDirectoryKey, NSURLContentModificationDateKey, nil];
	files = [[NSFileManager defaultManager] contentsOfDirectoryAtURL: path includingPropertiesForKeys: properties options: NSDirectoryEnumrationSkipsHiddenFiles error: &err];
	if (err) {
		// something is wrong have to handle it
		files = nil;
		return;
	}
	[files retain];
	[self showFilesWithFilter: @""];
}

- (void) showFilesWithFilter: (NSString *)filter {
	// remove current files in list
	if ([fileList numberOfRows] > 0) {
		[fileList removeRow: ([fileList numberOfRows] - 1)];
	}
	//
	if (files == nil) {
		[fileList setNeedsDisplay: YES];
		return;
	}
	for (NSURL *fileURL in files) {
		NSNumber *isDirectory = nil;
		[fileURL getResourceValue: &isDirectory forKey: NSURLIsDirectoryKey error: nil];
		if ([isDirectory boolValue]) {
			continue;
		}
		NSString *localizedName = nil;
		[fileURL getResourceValue: &localizedName forKey: NSURLLocalizedNameKey error: nil];
		
		bool searched = YES;
		if ([filter length]) {
			NSRange search = [localizedName rangeOfString: filter options: NSCaseInsensitiveSearch];
			searched = (search != NSNotFound);
		}

		if (searched) {
			NSTextFieldCell *cell = [[NSTextFieldCell alloc] initWithText: localizedName];
			[fileList addRowWithCells: [NSArray arrayWithObject: cell]];
			[cell release];
		}
	}
	[fileList setNeedsDisplay: YES];
}

- (void) controlTextDidChange: (NSNotification *)aNotification {
	NSTextField *filterField = [[aNotification userInfo] objectForKey: @"NSFieldEditor"];
	NSString *filter = [filterField stringValue];
	[self showFilesWithFilter: filter];
}
