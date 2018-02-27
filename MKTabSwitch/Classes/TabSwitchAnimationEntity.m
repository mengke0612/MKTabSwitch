//
//  TabSwitchAnimationEntity.m
//  SwitchableTab
//
//  Created by 孟珂 on 2017/10/27.
//  Copyright © 2017年 孟珂. All rights reserved.
//

#import "TabSwitchAnimationEntity.h"

#import <objc/runtime.h>

const char * relevanceTabKey ="SwitchRelevanceTabKey";

#define K_SCreenWidth [UIScreen mainScreen].bounds.size.width

#define K_SCreenHeight [UIScreen mainScreen].bounds.size.height

typedef NS_ENUM(NSInteger,TabOperationDirection) {
    
    TabLeftDirection,
    
    TabRightDirection
    
};
@interface TabSwitchAnimationEntity()<UITabBarControllerDelegate>
{
    BOOL isInterval;
}
@property (nonatomic, assign) TabOperationDirection tabScrollDirection;

@property(nonatomic,strong)UIPercentDrivenInteractiveTransition* percentTranstion;

@property(nonatomic,strong)UITabBarController * rootVC;

@end

@implementation TabSwitchAnimationEntity


-(instancetype)initWithRootViewController:(UITabBarController *)vc{
    
    self=[super init];
    if (self) {
        
        NSAssert([vc isKindOfClass:NSClassFromString(@"UITabBarController")], @"rootvc must be instance of UITabBarController Class");
        
        rootGesture =[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(ScreenEdgePanGestureEvent:)];
        self.rootVC=vc;
        self.rootVC.view.userInteractionEnabled=YES;
        
        [self.rootVC.view addGestureRecognizer:rootGesture];
        
        self.rootVC.delegate=self;
        self.percentTranstion=[[UIPercentDrivenInteractiveTransition alloc] init];
        
        isInterval=NO;
        
       
    }
   
    return self;
}



-(void)addGesture{
    
    
    
   
}

+(void)tabbarScrollSwitchConfigure:(UITabBarController *)vc{
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wincompatible-pointer-types"
    TabSwitchAnimationEntity *  entity= [[TabSwitchAnimationEntity alloc] initWithRootViewController:vc];
    #pragma clang diagnostic pop
    objc_setAssociatedObject(vc, relevanceTabKey, entity, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    
}

+(BOOL)tabbarIsScrollSwitch:(UITabBarController *)vc{
    
   TabSwitchAnimationEntity *  entity=  objc_getAssociatedObject(vc, relevanceTabKey);
    if (entity) {
        
       id isInterval= [entity valueForKey:@"isInterval"];
        
        return [isInterval boolValue];
    }
    
    else{
        
        return NO;
    }
    
}


-(void)ScreenEdgePanGestureEvent:(UIPanGestureRecognizer*)sender{
    
   UINavigationController * selectedN= self.rootVC.selectedViewController;
    
    if (selectedN.viewControllers.count>1) {
        
        return;
    }
    
   CGPoint point=   [sender translationInView:self.rootVC.view];
   
    CGFloat pecent=  fabs(point.x)/K_SCreenWidth;
    
    NSLog(@"point-----%@",[NSValue valueWithCGPoint:point]);
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
            
        {
            isInterval=YES;
            CGFloat velocityX = [sender velocityInView:self.rootVC.view].x;
            
            if (velocityX < 0) {
                
                if (self.rootVC.selectedIndex < self.rootVC.viewControllers.count - 1) {
                    
                    self.rootVC.selectedIndex += 1;
                    
                }
                
            }
            
            else {
                
                if (self.rootVC.selectedIndex > 0) {
                    
                    self.rootVC.selectedIndex -= 1;
                    
                }
                
            }
        }
            break;
            
        case UIGestureRecognizerStateChanged:
            
        {
            
            [self.percentTranstion updateInteractiveTransition:pecent];
            
        }
            
            
            
            break;
        case UIGestureRecognizerStateEnded:
            
        case UIGestureRecognizerStateFailed:
            
        case UIGestureRecognizerStateCancelled:
        {
            if (pecent<0.3) {
                
                self.percentTranstion.completionSpeed=0.99;
                
                [self.percentTranstion cancelInteractiveTransition];
            }
            else{
                self.percentTranstion.completionSpeed=0.99;
                [self.percentTranstion finishInteractiveTransition];
            }
            
            isInterval=NO;
        }
        default:
            break;
    }
    
   
}

#pragma mark UIViewControllerAnimatedTransitioning
-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    // 获取 toView fromView
    
    UIViewController* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    
    if (!toViewController || !fromViewController || !containerView) return;
    
    
    
    // 给 toView fromView 设定相应的值
    
    toViewController.view.transform = CGAffineTransformIdentity;
    
    fromViewController.view.transform = CGAffineTransformIdentity;
    
    CGFloat translation = containerView.frame.size.width;
    
    
    
    switch (self.tabScrollDirection) {
            
        case TabLeftDirection:
            
            translation = translation;
            
            break;
            
        case TabRightDirection:
            
            translation = -translation;
            
            break;
            
        default:
            
            break;
            
    }
    
    
    
    [containerView addSubview:toViewController.view];
    
    toViewController.view.transform = CGAffineTransformMakeTranslation(-translation, 0);
    
    // 真正的变化
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        
        fromViewController.view.transform = CGAffineTransformMakeTranslation(translation, 0);
        
        toViewController.view.transform = CGAffineTransformIdentity;
        
    } completion:^(BOOL finished) {
        
        fromViewController.view.transform = CGAffineTransformIdentity;
        
        toViewController.view.transform = CGAffineTransformIdentity;
        
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        
    }];
    
   
    
}

- (NSTimeInterval)transitionDuration:(nullable id<UIViewControllerContextTransitioning>)transitionContext {
    
    return 0.5;
}

#pragma mark UITabbarDelegate
- (nullable id <UIViewControllerInteractiveTransitioning>)tabBarController:(UITabBarController *)tabBarController
                               interactionControllerForAnimationController: (id <UIViewControllerAnimatedTransitioning>)animationController{
    
    
    return isInterval?self.percentTranstion:nil;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)tabBarController:(UITabBarController *)tabBarController
                     animationControllerForTransitionFromViewController:(UIViewController *)fromVC
                                                       toViewController:(UIViewController *)toVC{
    
    self.fromVC=fromVC;
    
    self.toVC  =toVC;
    
    NSInteger fromIndex = [tabBarController.viewControllers indexOfObject:fromVC];
    
    NSInteger toIndex = [tabBarController.viewControllers indexOfObject:toVC];
    
    self.tabScrollDirection = (toIndex < fromIndex) ? TabLeftDirection: TabRightDirection;
    
    
    
    return isInterval?self:nil;
    
    
    
    
}





@end

