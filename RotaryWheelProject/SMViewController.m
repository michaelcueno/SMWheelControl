//
//  SMViewController.m
//  RotaryWheelProject
//
//  Created by cesarerocchi on 2/10/12.
//  Copyright (c) 2012 studiomagnolia.com. All rights reserved.
//

#import "SMViewController.h"
#import "SMRotaryWheel.h"

@interface SMViewController()

@property (nonatomic, weak) SMRotaryWheel *wheel;

@end

@implementation SMViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    SMRotaryWheel *wheel = [[SMRotaryWheel alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    [wheel addTarget:self action:@selector(wheelDidChangeValue:) forControlEvents:UIControlEventValueChanged];
    wheel.delegate = self;
    wheel.dataSource = self;
    [wheel reloadData];

    [self.view addSubview:wheel];
    self.wheel = wheel;
}

#pragma mark - Wheel delegate

- (void)wheelDidEndDecelerating:(SMRotaryWheel *)wheel
{
    
}

- (void)wheel:(SMRotaryWheel *)wheel didRotateByAngle:(CGFloat)angle
{
    
}

#pragma mark - Wheel dataSource

- (NSUInteger)numberOfSlicesInWheel:(SMRotaryWheel *)wheel
{
    return 10;
}

- (UIView *)wheel:(SMRotaryWheel *)wheel viewForSliceAtIndex:(NSUInteger)index
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 30)];
    label.backgroundColor = [UIColor whiteColor];
    label.text = [NSString stringWithFormat:@" %d", index];
    return label;
}

#pragma mark - Wheel Control

- (void)wheelDidChangeValue:(id)sender
{
    self.valueLabel.text = [NSString stringWithFormat:@"%d", self.wheel.selectedIndex];
}


@end
