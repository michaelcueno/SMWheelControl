//
//  SMWheelControl.h
//  RotaryWheelProject
//
//  Created by cesarerocchi on 2/10/12.
//  Copyright (c) 2012 studiomagnolia.com. All rights reserved.


#import <UIKit/UIKit.h>
#import "SMWheelControlDelegate.h"
#import "SMWheelControlDataSource.h"

typedef enum {
    SMWheelControlStatusIdle,
    SMWheelControlStatusDecelerating,
    SMWheelControlStatusSnapping
} SMWheelControlStatus;

@protocol SMWheelControlDataSource;

@interface SMWheelControl : UIControl

@property (nonatomic, weak) id <SMWheelControlDelegate> delegate;
@property (nonatomic, weak) id <SMWheelControlDataSource> dataSource;
@property (nonatomic, assign) int selectedIndex;
@property (nonatomic, assign, readonly) SMWheelControlStatus status;

- (id)initWithFrame:(CGRect)frame;
- (void)reloadData;
- (void)setSelectedIndex:(int)selectedIndex animated:(BOOL)animated;
- (void)invalidateDecelerationDisplayLink;

@end
