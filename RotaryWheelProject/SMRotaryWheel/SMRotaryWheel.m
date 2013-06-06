//
//  SMRotaryWheel.m
//  RotaryWheelProject
//
//  Created by cesarerocchi on 2/10/12.
//  Copyright (c) 2012 studiomagnolia.com. All rights reserved.


#import "SMRotaryWheel.h"
#import <QuartzCore/QuartzCore.h>
#import "SMRotaryDataSource.h"

static CGFloat kDeltaAngle;
static CGFloat kMaxVelocity = 2000.0;
static CGFloat kDecelerationRate = 0.97;
static CGFloat kMinDeceleration = 0.1;

@interface SMRotaryWheel()

@property (nonatomic, strong) UIView *container;
@property (nonatomic, assign) int selectedIndex;

@end

@implementation SMRotaryWheel {
    BOOL _decelerating;
    CGFloat _animatingVelocity;
    CADisplayLink *_displayLink;
    CFTimeInterval _startTouchTime;
    CFTimeInterval _endTouchTime;
    CGFloat _angleChange;
    CGAffineTransform _startTransform;
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
		
        self.selectedIndex = 0;
		[self drawWheel];
        
	}
    return self;
}

- (void)clearWheel
{
    for (UIView *subview in self.container.subviews) {
        [subview removeFromSuperview];
    }
}

- (void)drawWheel
{
    self.container = [[UIView alloc] initWithFrame:self.frame];
    NSUInteger numberOfSlices = [self.dataSource numberOfSlicesInWheel:self];

    CGFloat angleSize = 2 * M_PI / numberOfSlices;
    
    for (int i = 0; i < numberOfSlices; i++) {
        
        UIView *sliceView = [self.dataSource wheel:self viewForSliceAtIndex:i];
        sliceView.layer.anchorPoint = CGPointMake(1.0f, 0.5f);
        sliceView.layer.position = CGPointMake(self.container.bounds.size.width / 2.0 - self.container.frame.origin.x,
                                        self.container.bounds.size.height / 2.0 - self.container.frame.origin.y);
        sliceView.transform = CGAffineTransformMakeRotation(angleSize * i);
        sliceView.tag = i;

        [self.container addSubview:sliceView];
    }
    
    self.container.userInteractionEnabled = NO;
    [self addSubview:self.container];
}


- (void)didEndRotationOnSliceAtIndex:(NSUInteger)index {
    self.selectedIndex = index;
    [self.delegate wheelDidEndDecelerating:self];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}


- (float)distanceFromCenter:(CGPoint)point
{
    CGPoint center = CGPointMake(self.bounds.size.width/2.0f, self.bounds.size.height/2.0f);
	float dx = point.x - center.x;
	float dy = point.y - center.y;
	return sqrt(dx * dx + dy * dy);
}


#pragma mark - Touches

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (_decelerating) {
        [self endDeceleration];
    }

    CGPoint touchPoint = [touch locationInView:self];
    float dist = [self distanceFromCenter:touchPoint];
    
    if (dist < 40 || dist > 100) 
    {
        return NO;
    }

    _startTouchTime = _endTouchTime = CACurrentMediaTime();
    _angleChange = 0;
    
	float dx = touchPoint.x - self.container.center.x;
	float dy = touchPoint.y - self.container.center.y;
	kDeltaAngle = atan2(dy, dx);
    
    _startTransform = self.container.transform;
    
    return YES;
}


- (BOOL)continueTrackingWithTouch:(UITouch*)touch withEvent:(UIEvent*)event
{
    CGPoint pt = [touch locationInView:self];

    // If the change shows a really big jump, that means we've crossed the 0 degree line, and we need to calculate differently.
    // I'm sure there's a different way to do this, seems hackish, but it works just fine.
    /*
    if (change > 100.0f) {
        change -=360.0f;
    }
    else if (change < -100.0f) {
        change +=360.0f;
    }
    */

    _startTouchTime = _endTouchTime;
    _endTouchTime = CACurrentMediaTime();
    
    float dist = [self distanceFromCenter:pt];
    
    if (dist < 40 || dist > 100) {
        // NSLog(@"drag path too close to the center (%f,%f)", pt.x, pt.y);
    }
	
	float dx = pt.x  - self.container.center.x;
	float dy = pt.y  - self.container.center.y;
	float ang = atan2(dy, dx);
    
    float angleDifference = kDeltaAngle - ang;
    _angleChange = angleDifference;

    self.container.transform = CGAffineTransformRotate(_startTransform, -angleDifference);
    
    if ([self.delegate respondsToSelector:@selector(wheel:didRotateByAngle:)]) {
        [self.delegate wheel:self didRotateByAngle:angleDifference];
    }
    
    return YES;
}


- (void)endTrackingWithTouch:(UITouch*)touch withEvent:(UIEvent*)event
{
    [self beginDeceleration];
}


#pragma mark - Positioning

- (void)snapToNearestClove
{
    CGFloat radians = atan2f(self.container.transform.b, self.container.transform.a);

    int numberOfSlices = [self.dataSource numberOfSlicesInWheel:self];
    double radiansPerSlice = 2.0 * M_PI / numberOfSlices;
    int closestSlice = round(radians / radiansPerSlice);
    double snappedRadians = (double)closestSlice * radiansPerSlice;
    
    [UIView animateWithDuration:(snappedRadians - radians) / 0.1
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGAffineTransform t = CGAffineTransformMakeRotation(snappedRadians);
                         self.container.transform = t;
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             [self didEndRotationOnSliceAtIndex:closestSlice % numberOfSlices];
                         }     
                     }];
}


#pragma mark - Inertia

- (void)beginDeceleration
{
    CGFloat v = [self velocity];
    
    if (v != 0) {
        _decelerating = YES;
        _animatingVelocity = v;
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(decelerationStep)];
        _displayLink.frameInterval = 1;
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }
}


-(void)decelerationStep
{
    CGFloat newVelocity = _animatingVelocity * kDecelerationRate;
    
    CGFloat angle = _animatingVelocity / 60.0;

    if (newVelocity <= kMinDeceleration && newVelocity >= -kMinDeceleration) {
        [self endDeceleration];
    } else {
        _animatingVelocity = newVelocity;
        
        self.container.transform = CGAffineTransformRotate(self.container.transform, -angle);
        
        if ([self.delegate respondsToSelector:@selector(wheel:didRotateByAngle:)]) {
            [self.delegate wheel:self didRotateByAngle:angle];
        }
    }
}


-(void)endDeceleration
{
    _decelerating = NO;
    [_displayLink invalidate], _displayLink = nil;
    
    [self snapToNearestClove];
}


#pragma mark - Accessory methods

- (CGFloat)velocity
{
    CGFloat velocity = 0.0;

    if (_startTouchTime != _endTouchTime) {
        velocity = _angleChange / (_endTouchTime - _startTouchTime) / 10.0;
    }

    if (velocity > kMaxVelocity) {velocity = kMaxVelocity;}
    else if (velocity < -kMaxVelocity) {velocity = -kMaxVelocity;}

    return velocity;
}

- (void)reloadData
{
    [self clearWheel];
    [self drawWheel];
}

@end
