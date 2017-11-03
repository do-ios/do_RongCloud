//
//  UIColor+DORCColor.h
//  Do_Test
//
//  Created by wl on 2017/4/14.
//  Copyright © 2017年 DoExt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (DORCColor)

+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;

// UIColor 转UIImage
+ (UIImage *)imageWithColor:(UIColor *)color;

@end