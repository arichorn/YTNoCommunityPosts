#import <UIKit/UIKit.h>
#import <rootless.h>

#define LOC(x) [tweakBundle localizedStringForKey:x value:nil table:nil]

@class YTSettingsCell;

@interface YTSettingsSectionItem : NSObject
@property BOOL hasSwitch;
@property BOOL switchVisible;
@property BOOL on;
@property BOOL (^switchBlock)(YTSettingsCell *, BOOL);
@property int settingItemId;
- (instancetype)initWithTitle:(NSString *)title titleDescription:
(NSString *)titleDescription;
@end

@interface _ASCollectionViewCell : UICollectionViewCell
- (id)node;
@end

@interface YTAsyncCollectionView : UICollectionView
@end

@interface YTCommentNode : NSObject
@end

%hook YTSettingsViewController
- (void)setSectionItems:(NSMutableArray <YTSettingsSectionItem *> 
*)sectionItems forCategory:(NSInteger)category title:(NSString 
*)title titleDescription:(NSString *)titleDescription headerHidden:
(BOOL)headerHidden {

if (category == 1) {

YTSettingsSectionItem *commpost = 
[[%c(YTSettingsSectionItem) alloc] initWithTitle:NSLocalizedString(@"SHOW_COMMUNITY_POSTS", @"") titleDescription:NSLocalizedString(@"SHOW_COMMUNITY_POSTS_DESC", @"")];

commpost.hasSwitch = YES;
commpost.switchVisible = YES;
commpost.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"show_comm_posts"];

commpost.switchBlock = ^BOOL (YTSettingsCell *cell, BOOL enabled) {

[[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"show_comm_posts"];

return YES;

};
[sectionItems addObject:commpost];

}
%orig(sectionItems, category, title, titleDescription, headerHidden);

}
%end

%hook YTAsyncCollectionView
- (id)cellForItemAtIndexPath:(NSIndexPath *)indexPath {

if (![[NSUserDefaults standardUserDefaults] boolForKey:@"show_comm_posts"]) {

UICollectionViewCell *cell = %orig;
if ([cell isKindOfClass:NSClassFromString(@"_ASCollectionViewCell")]) {

_ASCollectionViewCell *cell = %orig;

NSString *result = [[[[cell node] accessibilityElements] valueForKey:@"description"] componentsJoinedByString:@""];

if ([result rangeOfString:NSLocalizedString(@"id.ui.backstage.post", @"")].location != NSNotFound) {

[self deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];

}

}

}
return %orig;

}
%end
