#import <UIKit/UIKit.h>

#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]

@interface SSItemOffer : NSObject
@property (readonly, assign, nonatomic) long long estimatedDiskSpaceNeeded;
@end

@interface SUItem : NSObject
@property (readonly, assign, nonatomic) SSItemOffer *defaultStoreOffer;
@property (assign, nonatomic, getter=isGameCenterEnabled) BOOL gameCenterEnabled;
@end

%hook ASUpdatePageView

- (void)_reloadHeaderView
{
	%orig;
	
	UIView *hdrView = MSHookIvar<UIView *>(self, "_headerView");
	SUItem *item = MSHookIvar<SUItem *>(self, "_item");
	SSItemOffer *offer = item.defaultStoreOffer;
	float size = (((float)offer.estimatedDiskSpaceNeeded)/1024)/1024;
	BOOL gameCenterEnabled = [item respondsToSelector:@selector(isGameCenterEnabled)] ? item.gameCenterEnabled : NO;
	
	if (![hdrView viewWithTag:435])
	{
		UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectZero];
		lbl.backgroundColor = [UIColor clearColor];
		lbl.font = [UIFont boldSystemFontOfSize:12.5f];
		lbl.textColor = RGB(65, 66, 66);
		lbl.text = [NSString stringWithFormat:@"%1.1f MB", size];
		lbl.shadowColor = [UIColor whiteColor];
		lbl.shadowOffset = CGSizeMake(0,1);
		hdrView.tag = 435;
		[lbl sizeToFit];
		lbl.frame = CGRectMake(310 - lbl.frame.size.width, gameCenterEnabled == YES ?  73 : 66, lbl.frame.size.width, lbl.frame.size.height);
		[hdrView addSubview:lbl];
		[lbl release];
	}
}

%end