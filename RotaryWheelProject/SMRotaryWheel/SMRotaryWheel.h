//
//  SMRotaryWheel.h
//  RotaryWheelProject
//
//  Created by cesarerocchi on 2/10/12.
//  Copyright (c) 2012 studiomagnolia.com. All rights reserved.


#import <UIKit/UIKit.h>
#import "SMRotaryProtocol.h"

@protocol SMRotaryDataSource;

@interface SMRotaryWheel : UIControl

@property (nonatomic, weak) id <SMRotaryProtocol> delegate;
@property (nonatomic, weak) id <SMRotaryDataSource> dataSource;

@property (nonatomic, strong) UIView *container;
@property int numberOfSections;
@property CGAffineTransform startTransform;
@property (nonatomic, strong) NSMutableArray *cloves;
@property int currentValue;


- (id) initWithFrame:(CGRect)frame andDelegate:(id)del withSections:(int)sectionsNumber;


@end
