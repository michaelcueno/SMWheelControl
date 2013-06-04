//
// Created by Simone Civetta on 6/4/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@class SMRotaryWheel;

@protocol SMRotaryDataSource <NSObject>

- (void)wheel:(SMRotaryWheel *)wheel viewForRowAtIndex:(NSUInteger)index;

@end