//
//  PreviewVideoUtil+Event.m
//  PreviewVideo
//
//  Created by Flow on 4/5/22.
//

#import "PreviewVideoUtil+Event.h"
#import <objc/runtime.h>

@implementation PreviewVideoUtil (Event)
#pragma mark - 绑定信号
+ (void)addPreViewEventForVerscrollView:(UIScrollView *)verscrollView {
    __weak UIViewController *viewController = verscrollView.viewController;
    if (viewController == nil) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self addPreViewEventForVerscrollView:verscrollView];
        });
        return;
    }
    
    [[viewController rac_signalForSelector:@selector(viewDidAppear:)] subscribeNext:^(RACTuple * _Nullable x) {
//        BOOL animated = [x.first boolValue];
        UIViewController *vc = viewController;
        [PreviewVideoUtil previewStartForVC:vc verticalScrollView:verscrollView];
    }];
    
    [[viewController rac_signalForSelector:@selector(viewDidDisappear:)] subscribeNext:^(RACTuple * _Nullable x) {
//        BOOL animated = [x.first boolValue];
        UIViewController *vc = viewController;
        [PreviewVideoUtil previewStopForVC:vc];
    }];
    
    // 滚动带惯性停止
    UIViewController *delegateVC = (UIViewController *)verscrollView.delegate;
    if ([delegateVC respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [[delegateVC rac_signalForSelector:@selector(scrollViewDidEndDecelerating:)] subscribeNext:^(RACTuple * _Nullable x) {
            // 手势滑动，然后慢慢停止的情况
            // UIScrollView *scrollView = x.first;
            UIViewController *vc = viewController;
            [PreviewVideoUtil previewStartForVC:vc verticalScrollView:verscrollView];
        }];
    }else {
        class_addMethod(delegateVC.class, @selector(scrollViewDidEndDecelerating:), (IMP)preview_scrollViewDidEndDecelerating_implementation, "v@:@");
    }
    
    // 拖拽停止
    if ([delegateVC respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [[delegateVC rac_signalForSelector:@selector(scrollViewDidEndDragging:willDecelerate:)] subscribeNext:^(RACTuple * _Nullable x) {
            // UIScrollView *scrollView = x.first;
            BOOL decelerate = [x.second boolValue];
            UIViewController *vc = viewController;
            if (decelerate != YES) {
                [PreviewVideoUtil previewStartForVC:vc verticalScrollView:verscrollView];
            }
        }];
    }else {
        class_addMethod(delegateVC.class, @selector(scrollViewDidEndDragging:willDecelerate:), (IMP)preview_scrollViewDidEndDragging_willDecelerate_implementation, "v@:@:s");
    }
    
    
    // reloadData
//    if ([verscrollView isKindOfClass:UITableView.class]) {
//        [[[verscrollView rac_signalForSelector:@selector(reloadData)] throttle:0.2] subscribeNext:^(RACTuple * _Nullable x) {
//            UIViewController *vc = viewController;
//            [PreviewVideoUtil previewStartForVC:vc verticalScrollView:verscrollView];
//        }];
//    }if ([verscrollView isKindOfClass:UICollectionView.class]) {
//        [[[verscrollView rac_signalForSelector:@selector(reloadData)] throttle:0.5] subscribeNext:^(RACTuple * _Nullable x) {
//            UIViewController *vc = viewController;
//            [PreviewVideoUtil previewStartForVC:vc verticalScrollView:verscrollView];
//        }];
//    }
    
}

void preview_scrollViewDidEndDecelerating_implementation(id self, SEL _cmd, UIScrollView *scrollView)
{
    UIViewController *vc = scrollView.viewController;
    [PreviewVideoUtil previewStartForVC:vc verticalScrollView:scrollView];
}

void preview_scrollViewDidEndDragging_willDecelerate_implementation(id self, SEL _cmd, UIScrollView *scrollView, bool decelerate)
{
    if (decelerate != YES) {
        UIViewController *vc = scrollView.viewController;
        [PreviewVideoUtil previewStartForVC:vc verticalScrollView:scrollView];
    }
}

#pragma mark 具体要展示预览的视图
+ (void)addShowRectView:(UIView *)rectView imageView:(UIImageView *)imageView videoUrlBlock:(PreviewGetVideoUrlBlock)urlBlock {
    __weak UIImageView *realImageView = imageView;
    [PreviewVideoUtil.sharedInstance.startPreviewSubject subscribeNext:^(RACTuple *  _Nullable x) {
        UIViewController *vc = x.first;
        UIScrollView *verticalScrollView = x.second;
        if (realImageView.viewController != vc) {
            // 不是当前的vc，不处理这个通知
            return;
        }
        NSString *videoUrl = nil;
        if (urlBlock) {
            videoUrl = urlBlock();
        }
        [PreviewVideoUtil startPreviewforVC:vc rectView:rectView imageView:imageView videoUrl:videoUrl isPageBottom:verticalScrollView.isLastPage];
    }];
    [PreviewVideoUtil.sharedInstance.stopPreviewSubject subscribeNext:^(RACTuple  * _Nullable x) {
        UIViewController *vc = x.first;
        if (realImageView.viewController != vc) {
            // 不是当前的vc，不处理这个通知
            return;
        }
        // 收到停止播放的通知，停止播放
        [PreviewVideoUtil stopShowPreviewWithImageView:realImageView];
    }];
}
#pragma mark - public
+ (void)previewStartForVC:(UIViewController *)vc {
    [self previewStartForVC:vc verticalScrollView:nil];
}
+ (void)previewStartForVC:(UIViewController *)vc verticalScrollView:(UIScrollView *)verticalScrollView {
    if (vc == nil) {
        return;
    }
    RACTuple *tuple = nil;
    if (verticalScrollView != nil) {
        tuple = [RACTuple tupleWithObjects:vc,verticalScrollView, nil];
    }else {
        tuple = [RACTuple tupleWithObjects:vc, nil];
    }
    [PreviewVideoUtil.sharedInstance.startPreviewSubject sendNext:tuple];
}
+ (void)previewStopForVC:(UIViewController *)vc {
    if (vc == nil) {
        return;
    }
    [PreviewVideoUtil.sharedInstance.stopPreviewSubject sendNext:[RACTuple tupleWithObjects:vc, nil]];
}
@end
