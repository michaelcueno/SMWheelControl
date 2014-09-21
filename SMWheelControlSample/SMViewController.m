//
//  SMViewController.m
//  RotaryWheelProject
//
//  Created by cesarerocchi on 2/10/12.
//  Copyright (c) 2012 studiomagnolia.com. All rights reserved.
//

#import "SMViewController.h"
#import "SMWheelControl.h"

@interface SMViewController()

@property (nonatomic, weak) SMWheelControl *wheel;

@end

@implementation SMViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    SMWheelControl *wheel = [[SMWheelControl alloc] initWithFrame:self.wheelContainer.bounds];
    [wheel addTarget:self action:@selector(wheelDidChangeValue:) forControlEvents:UIControlEventValueChanged];
    [wheel insertSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WheelBackground"]] atIndex:0];
    wheel.delegate = self;
    wheel.dataSource = self;
    [wheel reloadData];

    [self.wheelContainer addSubview:wheel];
    self.wheel = wheel;
}

#pragma mark - Wheel delegate

- (void)wheelDidEndDecelerating:(SMWheelControl *)wheel
{
    
}

- (void)wheel:(SMWheelControl *)wheel didRotateByAngle:(CGFloat)angle
{
    
}

#pragma mark - Wheel dataSource

- (NSUInteger)numberOfSlicesInWheel:(SMWheelControl *)wheel
{
    return 10;
}

- (UIView *)wheel:(SMWheelControl *)wheel viewForSliceAtIndex:(NSUInteger)index
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 30)];
    label.backgroundColor = [UIColor whiteColor];
    label.text = [NSString stringWithFormat:@" %d", index];
    return label;
}

#pragma mark - Wheel Control

- (void)wheelDidChangeValue:(id)sender
{
    self.valueLabel.text = [NSString stringWithFormat:@"Selected index: %d", self.wheel.selectedIndex];
}

- (CGFloat)snappingAngleForWheel:(id)sender
{
    return M_PI / 2;
}

@end
