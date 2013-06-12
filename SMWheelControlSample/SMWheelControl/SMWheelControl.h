//
//  SMWheelControl.h
//  RotaryWheelProject
//
//  Created by cesarerocchi on 2/10/12.
//  Copyright (c) 2012 studiomagnolia.com. All rights reserved.


#import <UIKit/UIKit.h>
#import "SMWheelControlDelegate.h"
#import "SMWheelControlDataSource.h"

@protocol SMWheelControlDataSource;

static const CGFloat kMinDistanceFromCenter = 40.0;
static const CGFloat kMaxVelocity = 20.0;
static const CGFloat kDecelerationRate = 0.97;
static const CGFloat kMinDeceleration = 0.1;

@interface SMWheelControl : UIControl

@property (nonatomic, weak) id <SMWheelControlDelegate> delegate;
@property (nonatomic, weak) id <SMWheelControlDataSource> dataSource;
@property (nonatomic, assign, readonly) int selectedIndex;

- (id)initWithFrame:(CGRect)frame;
- (void)reloadData;

@end
