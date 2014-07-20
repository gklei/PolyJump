//
//  PJGameMetricProvider.h
//  PolyJump
//
//  Created by David Cheng on 7/20/14.
//  Copyright (c) 2014 Free the Robots. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PJGameMetricProvider <NSObject>

@property(nonatomic, readonly) CGPoint trackCenter;
@property(nonatomic, readonly) CGFloat preparingTrackRadius;
@property(nonatomic, readonly) CGFloat trackRadius;

@end
