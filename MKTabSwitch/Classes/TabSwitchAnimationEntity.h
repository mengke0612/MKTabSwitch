//
//  TabSwitchAnimationEntity.h
//  SwitchableTab
//
//  Created by 孟珂 on 2017/10/27.
//  Copyright © 2017年 孟珂. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface TabSwitchAnimationEntity : NSObject<UIViewControllerAnimatedTransitioning>
{
    
    UIPanGestureRecognizer * rootGesture;
    
    
}


@property(nonatomic,weak)UIViewController* fromVC;

@property(nonatomic,weak)UIViewController* toVC;



-(instancetype)initWithRootViewController:(UITabBarController*)vc;


+(void)tabbarScrollSwitchConfigure:(UITabBarController*)vc;

+(BOOL)tabbarIsScrollSwitch:(UITabBarController*)vc;

@end
