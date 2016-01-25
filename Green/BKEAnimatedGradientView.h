//
//  BKEAnimatedGradientView.h
//  BKEAnimatedGradientView
//
//  Created by Brian Kenny on 03/02/2014.
//  Copyright (c) 2014 Brian Kenny. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BKEAnimatedGradientView : UIView

/*
 Array of Colors
*/
@property (nonatomic, copy) NSArray *gradientColors;

- (void)changeGradientWithAnimation:(NSArray *)gradientColors delay:(float)delay duration:(float)duration;

@end
