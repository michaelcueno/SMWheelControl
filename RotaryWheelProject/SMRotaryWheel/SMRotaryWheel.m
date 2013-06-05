//
//  SMRotaryWheel.m
//  RotaryWheelProject
//
//  Created by cesarerocchi on 2/10/12.
//  Copyright (c) 2012 studiomagnolia.com. All rights reserved.


#import "SMRotaryWheel.h"
#import <QuartzCore/QuartzCore.h>
#import "SMClove.h"
#import "SMRotaryDataSource.h"

static CGFloat kDeltaAngle;
static CGFloat kMinAlphaValue = 0.6;
static CGFloat kMaxAlphaValue = 1.0;
static CGFloat kMaxVelocity = 2000.0;
static CGFloat kDecelerationRate = 0.97;

@implementation SMRotaryWheel {
    BOOL _decelerating;
    CGFloat _animatingVelocity;
    CADisplayLink *_displayLink;
    CFTimeInterval _startTouchTime;
    CFTimeInterval _endTouchTime;
    CGFloat _angleChange;
}

- (id) initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
		
        self.currentValue = 0;
        [self clearWheel];
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

- (void) drawWheel
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
        sliceView.alpha = kMinAlphaValue;
        sliceView.tag = i;
        
        if (i == 0) {
            sliceView.alpha = kMaxAlphaValue;
        }

        [self.container addSubview:sliceView];
    }
    
    self.container.userInteractionEnabled = NO;
    [self addSubview:self.container];
    
    UIImageView *bg = [[UIImageView alloc] initWithFrame:self.frame];
    bg.image = [UIImage imageNamed:@"bg.png"];
    [self addSubview:bg];
    
    UIImageView *mask = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 58, 58)];
    mask.image =[UIImage imageNamed:@"centerButton.png"] ;
    mask.center = self.center;
    mask.center = CGPointMake(mask.center.x, mask.center.y+3);
    [self addSubview:mask];
    
    if (numberOfSlices % 2 == 0) {
        [self buildClovesEven];
    } else {
        [self buildClovesOdd];
    }

    #warning implement this
    //[self.delegate wheel:self didChangeValue:[self getCloveName:currentValue]];
}


- (UIImageView *) getCloveByValue:(int)value
{
    UIImageView *res;
    
    NSArray *views = [self.container subviews];
    
    for (UIImageView *im in views) {
        
        if (im.tag == value) {
            res = im;
        }
    }
    
    return res;
}


- (void) buildClovesEven
{
    NSUInteger numberOfSlices = [self.dataSource numberOfSlicesInWheel:self];

    CGFloat fanWidth = M_PI * 2 / numberOfSlices;
    CGFloat mid = 0;
    
    for (int i = 0; i < numberOfSlices; i++) {
        
        SMClove *clove = [[SMClove alloc] init];
        clove.midValue = mid;
        clove.minValue = mid - (fanWidth/2);
        clove.maxValue = mid + (fanWidth/2);
        clove.value = i;
        
        
        if (clove.maxValue-fanWidth < - M_PI) {
            
            mid = M_PI;
            clove.midValue = mid;
            clove.minValue = fabsf(clove.maxValue);
            
        }
        
        mid -= fanWidth;
        
        NSLog(@"cl is %@", clove);
        
        // [self.cloves addObject:clove];
        
    }    
}


- (void) buildClovesOdd
{
    NSUInteger numberOfSlices = [self.dataSource numberOfSlicesInWheel:self];

    CGFloat fanWidth = M_PI * 2 / numberOfSlices;
    CGFloat mid = 0;
    
    for (int i = 0; i < numberOfSlices; i++) {
        
        SMClove *clove = [[SMClove alloc] init];
        clove.midValue = mid;
        clove.minValue = mid - (fanWidth/2);
        clove.maxValue = mid + (fanWidth/2);
        clove.value = i;
        
        mid -= fanWidth;
        
        if (clove.minValue < - M_PI) {
            
            mid = -mid;
            mid -= fanWidth; 
            
        }
        
                
        //[self.cloves addObject:clove];
        
        NSLog(@"cl is %@", clove);
    }
}


- (float) calculateDistanceFromCenter:(CGPoint)point
{
    
    CGPoint center = CGPointMake(self.bounds.size.width/2.0f, self.bounds.size.height/2.0f);
	float dx = point.x - center.x;
	float dy = point.y - center.y;
	return sqrt(dx*dx + dy*dy);
    
}


#pragma mark - Touches

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (_decelerating) {
        [self endDeceleration];
    }

    _startTouchTime = _endTouchTime = CACurrentMediaTime();
    _angleChange = 0;

    CGPoint touchPoint = [touch locationInView:self];
    float dist = [self calculateDistanceFromCenter:touchPoint];
    
    if (dist < 40 || dist > 100) 
    {
        // forcing a tap to be on the ferrule
        NSLog(@"ignoring tap (%f,%f)", touchPoint.x, touchPoint.y);
        return NO;
    }
    
	float dx = touchPoint.x - self.container.center.x;
	float dy = touchPoint.y - self.container.center.y;
	kDeltaAngle = atan2(dy, dx);
    
    self.startTransform = self.container.transform;
    
    UIImageView *im = [self getCloveByValue:self.currentValue];
    im.alpha = kMinAlphaValue;

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
    
    float dist = [self calculateDistanceFromCenter:pt];
    
    if (dist < 40 || dist > 100) {
        // a drag path too close to the center
        NSLog(@"drag path too close to the center (%f,%f)", pt.x, pt.y);
        
        // here you might want to implement your solution when the drag 
        // is too close to the center
        // You might go back to the clove previously selected
        // or you might calculate the clove corresponding to
        // the "exit point" of the drag.
    }
	
	float dx = pt.x  - self.container.center.x;
	float dy = pt.y  - self.container.center.y;
	float ang = atan2(dy,dx);
    
    float angleDifference = kDeltaAngle - ang;
    _angleChange = angleDifference;

    self.container.transform = CGAffineTransformRotate(self.startTransform, -angleDifference);
    
    return YES;	
}


- (void)endTrackingWithTouch:(UITouch*)touch withEvent:(UIEvent*)event
{
    UIImageView *im = [self getCloveByValue:self.currentValue];
    im.alpha = kMaxAlphaValue;

    [self beginDeceleration];
}


#pragma mark - Positioning

- (void)snapToNearestClove
{
    CGFloat radians = atan2f(self.container.transform.b, self.container.transform.a);
    
    double radiansPerSlice = 2.0 * M_PI / (float)[self.dataSource numberOfSlicesInWheel:self];
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
                             [self.delegate wheelDidEndDecelerating:self];
                         }     
                     }];
}


#pragma mark - Inertia

- (void)beginDeceleration
{
    CGFloat v = [self velocity];
    // NSLog(@"Velocity: %f", v);

    // Taking a risk here that the delegate will not change or be destroyed while we're in the middle of animating the deceleration
    
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

    if (newVelocity <= 0.1 && newVelocity >= -0.1) {
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

    if ([self.delegate respondsToSelector:@selector(wheelDidEndDecelerating:)]) {
        [self.delegate wheelDidEndDecelerating:self];
    }
}


#pragma mark - Accessory methods

- (CGFloat)velocity
{
    CGFloat velocity = 0.0;

    // Speed = distance/time (degrees/seconds)
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
