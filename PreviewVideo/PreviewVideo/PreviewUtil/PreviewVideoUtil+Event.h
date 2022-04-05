//
//  PreviewVideoUtil+Event.h
//  PreviewVideo
//
//  Created by Flow on 4/5/22.
//

#import "PreviewVideoUtil.h"

NS_ASSUME_NONNULL_BEGIN

typedef NSString *_Nullable(^PreviewGetVideoUrlBlock)(void);

@interface PreviewVideoUtil (Event)

/// 需要展示视频预览的页面
/// @param scrollView 竖直滚动的scrollView（UITableView、UICollectionView）
+ (void)addPreViewEventForVerscrollView:(UIScrollView *)scrollView;
+ (void)addShowRectView:(UIView *)rectView
              imageView:(UIImageView *)imageView
          videoUrlBlock:(PreviewGetVideoUrlBlock)urlBlock;

#pragma mark - 手动触发（极少场景使用到）
/// 用于特定场景下手动触发开始或关闭视频预览
+ (void)previewStartForVC:(UIViewController *)vc;
@end

NS_ASSUME_NONNULL_END
