//
//  AIPlayerNode.h
//  PolyJump
//
//  Created by David Cheng on 7/19/14.
//  Copyright (c) 2014 Free the Robots. All rights reserved.
//

#import "PlayerNode.h"

@interface AIPlayerNode : PlayerNode

@property(nonatomic) CGFloat difficulty;

+(AIPlayerNode *)aiPlayerNodeWithGameMetricProvider:(id<PJGameMetricProvider>)gameMetricProvider;

@end
