//
//  BKEAnimatedGradientView.m
//  BKEAnimatedGradientView
//
//  Created by Brian Kenny on 03/02/2014.
//  Copyright (c) 2014 Brian Kenny. All rights reserved.
//

#import "BKEAnimatedGradientView.h"

@interface BKEAnimatedGradientView()

@property (nonatomic, retain) CAGradientLayer *gradient;
@property float duration;

@end

@implementation BKEAnimatedGradientView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

-(void)setup {
    _gradient = [CAGradientLayer layer];
    _gradient.frame = self.frame;
    [self.layer addSublayer:_gradient];
}

- (void)setGradientColors:(NSArray *)gradientColors {
    _gradientColors = gradientColors;
    NSMutableArray *cgColors = [NSMutableArray new];
    
    for (UIColor *color in _gradientColors) {
        [cgColors addObject:(id)color.CGColor];
    }
    
    _gradientColors = cgColors;
    
    [self refreshGradient];
}

- (void)refreshGradient {
    _gradient.colors = _gradientColors;
}

#pragma Changing the gradient

- (void)changeGradientWithAnimation:(NSArray *)gradientColors delay:(float)delay duration:(float)duration {
    _duration = duration;
    [self performSelector:@selector(startAnimation:) withObject:gradientColors afterDelay:delay];
}

- (void)startAnimation:(NSArray *)gradientColors {
    [UIView animateWithDuration:_duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [CATransaction begin];
        [CATransaction setAnimationDuration:_duration];
        
        [self setGradientColors:gradientColors];
        
        [CATransaction commit];
    } completion:nil];
}

@end
