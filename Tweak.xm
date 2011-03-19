/* AppStoreUpdateSize
 * This is a nasty way to get around Apples changes to how updates are displayed (but it works, mostly).
 */

#import <UIKit/UIKit.h>

#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]

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
