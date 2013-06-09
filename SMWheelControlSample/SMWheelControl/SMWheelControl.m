//
//  SMWheelControl.m
//  RotaryWheelProject
//
//  Created by cesarerocchi on 2/10/12.
//  Copyright (c) 2012 studiomagnolia.com. All rights reserved.


#import "SMWheelControl.h"
#import <QuartzCore/QuartzCore.h>
#import "SMWheelControlDataSource.h"

@interface SMWheelControl ()

@property (nonatomic, strong) UIView *sliceContainer;
@property (nonatomic, assign) int selectedIndex;

@end

@implementation SMWheelControl {
    BOOL _decelerating;
    CGFloat _animatingVelocity;
    CADisplayLink *_displayLink;
    CFTimeInterval _startTouchTime;
    CFTimeInterval _endTouchTime;
    CGFloat _angleDelta;
    CGAffineTransform _initialTransform;
    CGFloat _initialAngle;
    CGFloat _previousAngle;
    CGFloat _currentAngle;
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
    for (UIView *subview in self.sliceContainer.subviews) {
        [subview removeFromSuperview];
    }
}

- (void)drawWheel
{
    self.sliceContainer = [[UIView alloc] initWithFrame:self.frame];
    NSUInteger numberOfSlices = [self.dataSource numberOfSlicesInWheel:self];

    CGFloat angleSize = 2 * M_PI / numberOfSlices;
    
    for (int i = 0; i < numberOfSlices; i++) {
        
        UIView *sliceView = [self.dataSource wheel:self viewForSliceAtIndex:i];
        sliceView.layer.anchorPoint = CGPointMake(1.0f, 0.5f);
        sliceView.layer.position = CGPointMake(self.sliceContainer.bounds.size.width / 2.0 - self.sliceContainer.frame.origin.x,
                                        self.sliceContainer.bounds.size.height / 2.0 - self.sliceContainer.frame.origin.y);
        sliceView.transform = CGAffineTransformMakeRotation(angleSize * i);

        [self.sliceContainer addSubview:sliceView];
    }
    
    self.sliceContainer.userInteractionEnabled = NO;
    [self addSubview:self.sliceContainer];
}


- (void)didEndRotationOnSliceAtIndex:(NSUInteger)index
{
    self.selectedIndex = index;
    if ([self.delegate respondsToSelector:@selector(wheelDidEndDecelrating:)]) {
        [self.delegate wheelDidEndDecelerating:self];
    }
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}


#pragma mark - Touches

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (_decelerating) {
        [self.sliceContainer.layer removeAllAnimations];
        [self endDecelerationAvoidingSnap:YES];
    }

    CGPoint touchPoint = [touch locationInView:self];
    float dist = [self distanceFromCenter:touchPoint];
    
    if (dist < kMinDistanceFromCenter)
    {
        return NO;
    }

    _startTouchTime = _endTouchTime = CACurrentMediaTime();
    _angleDelta = 0;
    
    float dx = touchPoint.x - self.sliceContainer.center.x;
	float dy = touchPoint.y - self.sliceContainer.center.y;

	_initialAngle = _currentAngle = _previousAngle = atan2f(dy, dx);
    _initialTransform = self.sliceContainer.transform;
    
    return YES;
}


- (BOOL)continueTrackingWithTouch:(UITouch*)touch withEvent:(UIEvent*)event
{
    CGPoint pt = [touch locationInView:self];

    _startTouchTime = _endTouchTime;
    _endTouchTime = CACurrentMediaTime();
    
    float dist = [self distanceFromCenter:pt];
    
    if (dist < kMinDistanceFromCenter) {
        // NSLog(@"drag path too close to the center (%f,%f)", pt.x, pt.y);
        return NO;        
    }

	float dx = pt.x - self.sliceContainer.center.x;
	float dy = pt.y - self.sliceContainer.center.y;

    _previousAngle = _currentAngle;
	_currentAngle = atan2f(dy, dx);

    _angleDelta = _initialAngle - _currentAngle;

    self.sliceContainer.transform = CGAffineTransformRotate(_initialTransform, -_angleDelta);
    
    if ([self.delegate respondsToSelector:@selector(wheel:didRotateByAngle:)]) {
        [self.delegate wheel:self didRotateByAngle:_angleDelta];
    }
    
    return YES;
}


- (void)endTrackingWithTouch:(UITouch*)touch withEvent:(UIEvent*)event
{
    [self beginDeceleration];
}


#pragma mark - Positioning

- (void)snapToNearestSlice
{
    CGFloat radians = atan2f(self.sliceContainer.transform.b, self.sliceContainer.transform.a);
    
    if (radians < 0) {
        radians += 2.0 * M_PI;
    }

    int numberOfSlices = [self.dataSource numberOfSlicesInWheel:self];
    double radiansPerSlice = 2.0 * M_PI / numberOfSlices;
    int closestSlice = round(radians / radiansPerSlice);
    double snappedRadians = (double)closestSlice * radiansPerSlice;
    
    [UIView animateWithDuration:(snappedRadians - radians) / 0.1
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         CGAffineTransform t = CGAffineTransformMakeRotation(snappedRadians);
                         self.sliceContainer.transform = t;
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             [self didEndRotationOnSliceAtIndex:
                              (closestSlice == 0 || closestSlice == numberOfSlices) ?
                              0 :
                              (numberOfSlices - closestSlice % numberOfSlices)];
                         }     
                     }];
}


#pragma mark - Inertia

- (void)beginDeceleration
{
    _animatingVelocity = [self velocity];
    
    if (_animatingVelocity != 0) {
        _decelerating = YES;
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(decelerationStep)];
        _displayLink.frameInterval = 1;
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    } else {
        [self snapToNearestSlice];
    }
}


- (void)decelerationStep
{
    CGFloat newVelocity = _animatingVelocity * kDecelerationRate;
    
    CGFloat angle = _animatingVelocity / 60.0;

    if (newVelocity <= kMinDeceleration && newVelocity >= -kMinDeceleration) {
        [self endDecelerationAvoidingSnap:NO];
    } else {
        _animatingVelocity = newVelocity;
        
        self.sliceContainer.transform = CGAffineTransformRotate(self.sliceContainer.transform, -angle);
        
        if ([self.delegate respondsToSelector:@selector(wheel:didRotateByAngle:)]) {
            [self.delegate wheel:self didRotateByAngle:angle];
        }
    }
}


- (void)endDecelerationAvoidingSnap:(BOOL)avoidSnap
{
    [_displayLink invalidate], _displayLink = nil;

    if (!avoidSnap) {
        [self snapToNearestSlice];
    }
    
    _decelerating = NO;
}


#pragma mark - Accessory methods

- (CGFloat)velocity
{
    CGFloat velocity = 0.0;

    if (_startTouchTime != _endTouchTime) {
        velocity = (_previousAngle - _currentAngle) / (_endTouchTime - _startTouchTime);
    }

    if (velocity > kMaxVelocity) {
        velocity = kMaxVelocity;
    } else if (velocity < -kMaxVelocity) {
        velocity = -kMaxVelocity;
    }

    return velocity;
}


- (float)distanceFromCenter:(CGPoint)point
{
    CGPoint center = CGPointMake(self.bounds.size.width/2.0f, self.bounds.size.height/2.0f);
    float dx = point.x - center.x;
    float dy = point.y - center.y;
    return sqrt(dx * dx + dy * dy);
}


- (void)reloadData
{
    [self clearWheel];
    [self drawWheel];
}



@end
