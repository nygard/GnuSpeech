#import "CategoryInspector.h"

#import <AppKit/AppKit.h>
#import "CategoryNode.h"
#import "Inspector.h"

@implementation CategoryInspector

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
{
    NSLog(@"<%@>[%p]  > %s", NSStringFromClass([self class]), self, _cmd);
    NSLog(@"commentView: %p", commentView);
    [commentView retain];
    [categoryPopUpListView retain];
    NSLog(@"<%@>[%p] <  %s", NSStringFromClass([self class]), self, _cmd);
}

- (void)dealloc;
{
    [commentView release];
    [categoryPopUpListView release];

    [currentCategory release];

    [super dealloc];
}

- (void)setCurrentCategory:(CategoryNode *)aCategory;
{
    if (aCategory == currentCategory)
        return;

    [currentCategory release];
    currentCategory = [aCategory retain];
}

- (void)inspectCategory:(CategoryNode *)aCategory;
{
    [self setCurrentCategory:aCategory];
    [mainInspector setPopUpListView:categoryPopUpListView];
    [self setUpWindow:categoryPopUpList];
}

- (void)setUpWindow:(NSPopUpButton *)sender;
{
    NSString *str;

    str = [[sender selectedCell] title];
    if ([str hasPrefix:@"C"]) {
        /* Comment Window */
        [mainInspector setGeneralView:commentView];

        [setButton setTarget:self];
        [setButton setAction:@selector(setComment:)];

        [revertButton setTarget:self];
        [revertButton setAction:@selector(revertComment:)];

        if ([currentCategory comment] != nil)
            [commentText setString:[currentCategory comment]];
        else
            [commentText setString:@""];
    }
}

- (void)beginEditting;
{
    NSString *str;

    str = [[categoryPopUpList selectedCell] title];
    if ([str hasPrefix:@"C"]) {
        /* Comment Window */
        [commentText selectAll:self];
    }
}

- (IBAction)setComment:(id)sender;
{
    NSString *newComment;

    newComment = [[commentText string] copy]; // Need to copy, becuase it's mutable and owned by the NSTextView
    [currentCategory setComment:newComment];
    [newComment release];
}

- (IBAction)revertComment:(id)sender;
{
    if ([currentCategory comment] != nil)
        [commentText setString:[currentCategory comment]];
    else
        [commentText setString:@""];
}


@end
