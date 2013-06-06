//
// Created by Simone Civetta on 6/4/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@class SMWheelControl;

@protocol SMWheelControlDataSource <NSObject>

- (UIView *)wheel:(SMWheelControl *)wheel viewForSliceAtIndex:(NSUInteger)index;
- (NSUInteger)numberOfSlicesInWheel:(SMWheelControl *)wheel;

@end