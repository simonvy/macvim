#import <Cocoa/Cocoa.h>

@interface ProjectView : NSView <NSTextFieldDelegate> {
	NSMatrix *fileList;
	
	NSArray *files;
}

- (void) loadFilesInCurrentDirectory;

@end

@interface ProjectView (Private)

- (void) loadFilesInDirectory: (NSURL *)path;
- (void) showFilesWithFilter: (NSString *)filter;

@end


