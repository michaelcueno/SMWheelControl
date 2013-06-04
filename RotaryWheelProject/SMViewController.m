//
//  SMViewController.m
//  RotaryWheelProject
//
//  Created by cesarerocchi on 2/10/12.
//  Copyright (c) 2012 studiomagnolia.com. All rights reserved.
//

#import "SMViewController.h"
#import "SMRotaryWheel.h"

@implementation SMViewController

@synthesize  valueLabel;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 350, 120, 30)];
    valueLabel.textAlignment = UITextAlignmentCenter;
    valueLabel.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:valueLabel];
	
    SMRotaryWheel *wheel = [[SMRotaryWheel alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    wheel.delegate = self;
    wheel.dataSource = self;
    [wheel reloadData];
    
    wheel.center = CGPointMake(160, 240);
    [self.view addSubview:wheel];
    
    
    
}

#pragma mark - Wheel delegate

- (void)wheel:(SMRotaryWheel *)wheel didSelectValueAtIndex:(NSUInteger)newValue
{
    self.valueLabel.text = @"1";
}

- (void)wheelDidEndDecelerating:(SMRotaryWheel *)wheel
{
    
}

#pragma mark - Wheel dataSource

- (NSUInteger)numberOfSlicesInWheel:(SMRotaryWheel *)wheel
{
    return 8;
}

- (UIView *)wheel:(SMRotaryWheel *)wheel viewForSliceAtIndex:(NSUInteger)index
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 20)];
    label.backgroundColor = [UIColor blueColor];
    label.text = [NSString stringWithFormat:@"%d", index];
    return label;
}


@end
