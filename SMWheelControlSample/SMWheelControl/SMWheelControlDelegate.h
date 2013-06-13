//
//  SMWheelControlDelegate.h
//  RotaryWheelProject
//
//  Created by cesarerocchi on 2/10/12.
//  Copyright (c) 2012 studiomagnolia.com. All rights reserved.


#import <Foundation/Foundation.h>

@class SMWheelControl;

@protocol SMWheelControlDelegate <NSObject>

@optional
- (void)wheelDidEndDecelerating:(SMWheelControl *)wheel;
- (void)wheel:(SMWheelControl *)wheel didRotateByAngle:(CGFloat)angle;
- (void)wheel:(SMWheelControl *)wheel didTapOnSliceAtIndex:(NSUInteger)index;

@end
