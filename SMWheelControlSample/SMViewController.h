//
//  SMViewController.h
//  RotaryWheelProject
//
//  Created by cesarerocchi on 2/10/12.
//  Copyright (c) 2012 studiomagnolia.com. All rights reserved.


#import <UIKit/UIKit.h>
#import "SMWheelControl.h"

@interface SMViewController : UIViewController<SMWheelControlDelegate, SMWheelControlDataSource>

@property (nonatomic, weak) IBOutlet UILabel *valueLabel;

@end
