#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]

@interface DOMNode : NSObject
@property (readonly, retain) DOMNode *parentNode;
@property (copy) NSString *textContent;
- (id)getElementsByClassName:(NSString *)className;
@end

@interface DOMElement : DOMNode
- (id)getAttribute:(NSString *)attr;
@end

@interface DOMNodeList : NSObject
@property (readonly) NSUInteger length;
- (id)item:(NSUInteger)index;
@end

@interface DOMDocument : NSObject
@property (retain) DOMElement *body;
- (id)getElementsByClassName:(NSString *)className;
@end

@interface WebDataSource : NSObject
- (NSURLRequest *)initialRequest;
@end

@interface WebFrame : NSObject
- (DOMDocument *)DOMDocument;
- (WebDataSource *)dataSource;
@end

@interface SSItemOffer : NSObject
@property (readonly, assign, nonatomic) long long estimatedDiskSpaceNeeded;
@end

@interface SUItem : NSObject
@property (readonly, assign, nonatomic) SSItemOffer *defaultStoreOffer;
@end

@interface ASUpdatesViewController : UIViewController 
- (SUItem *)itemAtIndexPath:(NSIndexPath *)indexPath;
@end

float currentSize = 0.0f;

// iOS 5

%group iOS5

%hook WebDefaultUIKitDelegate

- (void)webView:(id)webView didFinishDocumentLoadForFrame:(WebFrame *)frame
{
    if ([[[[[frame dataSource] initialRequest] URL] absoluteString] isEqualToString:@"http://ax.su.itunes.apple.com/WebObjects/MZSoftwareUpdate.woa/wa/viewSoftwareUpdates"])
    {
        DOMDocument *doc = [frame DOMDocument];
        
        DOMNodeList *appDivs = [doc.body getElementsByClassName:@"buy redownload one-click hide"];
        
        for (NSUInteger i = 0; i < appDivs.length; i++)
        {
            DOMElement *app = [appDivs item:i];
            long long fileSize = [[app getAttribute:@"file-size"] longLongValue];
            float fileSizeMB = (float)fileSize/1024/1024;
            NSString *fileSizeStr = nil;
            
            if (fileSizeMB < 1.0)
                fileSizeStr = [NSString stringWithFormat:@" %i KB", (int)fileSize/1024];
            else if (fileSizeMB > 1000.0)
                fileSizeStr = [NSString stringWithFormat:@" %1.1f GB", (float)fileSizeMB/1024];
            else
                fileSizeStr = [NSString stringWithFormat:@" %1.1f MB", fileSizeMB];
            
            DOMNodeList *listNodeList = [app.parentNode.parentNode getElementsByClassName:@"list"];
            DOMNodeList *versionNodeList = [[listNodeList item:0] getElementsByClassName:@"version"];
            DOMNode *versionNode = [versionNodeList item:0];
            versionNode.textContent = [versionNode.textContent stringByAppendingString:fileSizeStr];
        }
    }
    
    %orig;
}

%end

%end

// iOS4.1 && 4.2.1

%group iOS4

%hook ASUpdatesViewController

- (BOOL)handleSelectionForIndexPath:(NSIndexPath *)indexPath tapCount:(int)tapCount
{
	SUItem *item = [self itemAtIndexPath:indexPath];
	currentSize = (float)item.defaultStoreOffer.estimatedDiskSpaceNeeded/1024/1024;
	return %orig;
}

%end

%hook SUStorePageViewController

- (void)_finishSuccessfulLoad
{
	%orig;
	
	UIView *scroll = [[[[[[[self view] subviews] objectAtIndex:0] subviews] objectAtIndex:0] subviews] objectAtIndex:0];
	
	UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectZero];
	lbl.backgroundColor = [UIColor clearColor];
	lbl.font = [UIFont boldSystemFontOfSize:12.5f];
	lbl.textColor = RGB(65, 66, 66);
	lbl.text = [NSString stringWithFormat:@"%1.1f MB", currentSize];
	lbl.shadowColor = [UIColor whiteColor];
	lbl.shadowOffset = CGSizeMake(0, 1);
	[lbl sizeToFit];
	lbl.frame = CGRectMake(305 - lbl.frame.size.width, 70, lbl.frame.size.width, lbl.frame.size.height);
	[scroll addSubview:lbl];
	[lbl release];
}

%end

%end

%ctor
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSString *version = [[UIDevice currentDevice] systemVersion];
    
    if ([version intValue] >= 5)
    {
        %init(iOS5);
    }
    else if ([version floatValue] >= 4.1 && [version floatValue] < 4.3)
    {
        %init(iOS4);
    }
    
    [pool drain];
}