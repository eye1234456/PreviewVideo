//
//  PreviewVideoUtil.h
//  PreviewVideo
//
//  Created by Flow on 4/5/22.
//

#import <UIKit/UIKit.h>
#import <ReactiveObjC/ReactiveObjC.h>

NS_ASSUME_NONNULL_BEGIN

@interface PreviewVideoUtil : NSObject
+ (instancetype)sharedInstance;
@property (nonatomic, strong) RACSubject *startPreviewSubject;
@property (nonatomic, strong) RACSubject *stopPreviewSubject;
@end

NS_ASSUME_NONNULL_END
