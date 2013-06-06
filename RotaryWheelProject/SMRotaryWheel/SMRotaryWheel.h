//
//  SMRotaryWheel.h
//  RotaryWheelProject
//
//  Created by cesarerocchi on 2/10/12.
//  Copyright (c) 2012 studiomagnolia.com. All rights reserved.


#import <UIKit/UIKit.h>
#import "SMRotaryProtocol.h"
#import "SMRotaryDataSource.h"

@protocol SMRotaryDataSource;

static const CGFloat kMinDistanceFromCenter = 40.0;
static const CGFloat kMaxVelocity = 2000.0;
static const CGFloat kDecelerationRate = 0.97;
static const CGFloat kMinDeceleration = 0.1;
static const float kVelocityCoefficient = 10.0;

@interface SMRotaryWheel : UIControl

@property (nonatomic, weak) id <SMRotaryProtocol> delegate;
@property (nonatomic, weak) id <SMRotaryDataSource> dataSource;
@property (nonatomic, assign, readonly) int selectedIndex;

- (id)initWithFrame:(CGRect)frame;
- (void)reloadData;

@end
