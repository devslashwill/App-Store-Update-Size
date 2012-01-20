#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]
#define IS_IPAD ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

@interface DOMNode : NSObject
@property (readonly, retain) DOMNode *parentNode;
@property (copy) NSString *innerHTML;
- (id)getElementsByClassName:(NSString *)className;
@end

@interface DOMElement : DOMNode
- (id)getAttribute:(NSString *)attr;
- (void)setAttribute:(NSString *)attr value:(NSString *)value;
@property (readonly, retain) DOMElement *firstElementChild;
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
- (NSString *)_stringByEvaluatingJavaScriptFromString:(NSString *)js;
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
        DOMNodeList *appDivs = [doc.body getElementsByClassName:@"lockup application"];
        
        for (NSUInteger i = 0; i < appDivs.length; i++)
        {
            DOMElement *app = [appDivs item:i];
            DOMElement *buyLine = [[app getElementsByClassName:@"buy-line"] item:0];
            DOMElement *infoDiv = [buyLine lastElementChild];
            long long fileSize = [[infoDiv getAttribute:@"file-size"] longLongValue];
            NSString *fileSizeStr = nil;
            
            if (fileSize < 1048576)
                fileSizeStr = [NSString stringWithFormat:@" %i KB", (int)fileSize/1024];
            else if (fileSize > 1073741824)
                fileSizeStr = [NSString stringWithFormat:@" %1.1f GB", (float)fileSize/1024/1024/1024];
            else
                fileSizeStr = [NSString stringWithFormat:@" %1.1f MB", (float)fileSize/1024/1024];
            
            if (IS_IPAD == YES)
            {
                DOMElement *list = [[app getElementsByClassName:@"list"] item:0];
                list.innerHTML = [NSString stringWithFormat:@"<li>%@</li>%@", fileSizeStr, list.innerHTML];
                [[list style] setPaddingTop:@"3px"];
            }
            else
            {
                DOMElement *versionNode = [[app getElementsByClassName:@"version"] item:0];
                versionNode.innerHTML = [versionNode.innerHTML stringByAppendingString:fileSizeStr];
            }
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