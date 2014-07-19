//
//  PlayerNode.h
//  PolyJump
//
//  Created by David Cheng on 7/9/14.
//  Copyright (c) 2014 Free the Robots. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef NS_OPTIONS(NSUInteger, PlayerState) {
   PlayerStateIdle = 0,
   PlayerStateJumping = 1,
   PlayerStatePunchingLeft = 2,
   PlayerStatePunchingRight = 3,
};

@interface PlayerNode : SKNode

@property(nonatomic, assign) PlayerState state;
@property(nonatomic, readonly) BOOL isIdle;

+(CGPoint)positionWithCenter:(CGPoint)center
                      radius:(CGFloat)radius
                       angle:(CGFloat)angleDegrees;
-(CGFloat)angleWithCenter:(CGPoint)center radius:(CGFloat)radius;

- (void)jump;
- (void)punchLeft;
- (void)punchRight;

- (void)update;

@end
