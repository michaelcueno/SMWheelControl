//
//  SMRotaryProtocol.h
//  RotaryWheelProject
//
//  Created by cesarerocchi on 2/10/12.
//  Copyright (c) 2012 studiomagnolia.com. All rights reserved.


#import <Foundation/Foundation.h>

@class SMRotaryWheel;

@protocol SMRotaryProtocol <NSObject>

- (void)wheel:(SMRotaryWheel *)wheel didSelectValueAtIndex:(NSUInteger)index;
- (void)wheelDidEndDecelerating:(SMRotaryWheel *)wheel;
- (void)wheel:(SMRotaryWheel *)wheel didRotateByAngle:(CGFloat)angle;

@end
