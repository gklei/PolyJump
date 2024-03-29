//
//  PJBarNode.h
//  PolyJump
//
//  Created by David Cheng on 7/9/14.
//  Copyright (c) 2014 Free the Robots. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface PJBarNode : SKShapeNode

@property(nonatomic) BOOL isAccelerating;
@property(nonatomic, readonly) CGFloat velocity;

+(PJBarNode *)nodeWithBarLength:(CGFloat)barLength;

-(void)updateWithDeltaTime:(NSTimeInterval)deltaTime;
-(void)reverseDirectionWithExtraHitPower:(CGFloat)extraHitPower;

@end
