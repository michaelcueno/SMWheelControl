# SMWheelControl
SMWheelControl is an iOS component allowing the selection of an item from a 360° spinning wheel with a smooth inertial rotation. 

The code is loosely based on the tutorial "How To Create a Rotating Wheel Control with UIKit" published on the post [http://www.raywenderlich.com/9864/how-to-create-a-rotating-wheel-control-with-uikit](http://www.raywenderlich.com/9864/how-to-create-a-rotating-wheel-control-with-uikit) by Cesare Rocchi.

Sample screenshot:

![The final result](https://github.com/viteinfinite/SMWheelControl/blob/master/final.png?raw=true "The final result")

# Usage

## Initialization and data source

Instantiate the control with a classical `- (id)initWithFrame:(CGRect)rect` and add a target as you usually do with a control, e.g.:

```objective-c

    SMWheelControl *wheel = [[SMWheelControl alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    [wheel addTarget:self action:@selector(wheelDidChangeValue:) forControlEvents:UIControlEventValueChanged];
```

Then add a dataSource:
```objective-c
wheel.dataSource = self;
[wheel reloadData];
```
and implement the following methods (the dataSource should conform to the `SMWheelControlDataSource`):
```objective-c
- (UIView *)wheel:(SMWheelControl *)wheel viewForSliceAtIndex:(NSUInteger)index
- (NSUInteger)numberOfSlicesInWheel:(SMWheelControl *)wheel
- (CGFloat)snappingAngleForWheel:(SMWheelControl *)wheel // optional
```

For instance:
```objective-c

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
```

When the wheel ends snapping to the closest slice, if you added a target, then it will receive the event `UIControlEventValueChanged`, e.g.: 
```objective-c
- (void)wheelDidChangeValue:(id)sender
{
    self.valueLabel.text = [NSString stringWithFormat:@"%d", self.wheel.selectedIndex];
}
```

The dataSource can also provide a snapping angle, i.e. the angle at which the wheel should snap to. This can be set via the optional method
`- (CGFloat)snappingAngleForWheel:(SMWheelControl *)wheel`

## Delegate
You can also implement the (hopefully self-explanatory) methods provided by `SMWheelControlDelegate`, i.e.:

```objective-c
- (void)wheelDidEndDecelerating:(SMWheelControl *)wheel;
- (void)wheel:(SMWheelControl *)wheel didRotateByAngle:(CGFloat)angle;
- (void)wheel:(SMWheelControl *)wheel didTapOnSliceAtIndex:(NSUInteger)index;
```
# Authors

The library is based on the work of
* Cesare Rocchi (@_funkyboy)

and currently developed by
* Simone Civetta (@viteinfinite) 
* Martin Moizard (@MartinMoizard)


# License
* [BSD 3-Clause](http://opensource.org/licenses/BSD-3-Clause)

