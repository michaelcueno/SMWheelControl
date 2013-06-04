//
//  SMViewController.h
//  RotaryWheelProject
//
//  Created by cesarerocchi on 2/10/12.
//  Copyright (c) 2012 studiomagnolia.com. All rights reserved.


#import <UIKit/UIKit.h>
#import "SMRotaryWheel.h"

@interface SMViewController : UIViewController<SMRotaryProtocol, SMRotaryDataSource>

@property (nonatomic, strong) UILabel *valueLabel;

@end
