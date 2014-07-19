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
   PlayerStateDead = 4,
};

@interface PlayerNode : SKNode

@property(nonatomic, assign) PlayerState state;
@property(nonatomic, assign) BOOL invincible;

@property(nonatomic, readonly) BOOL isIdle;
@property(nonatomic, readonly) BOOL isPunchingLeft;
@property(nonatomic, readonly) BOOL isPunchingRight;
@property(nonatomic, readonly) BOOL isJumping;

+(CGPoint)positionWithCenter:(CGPoint)center
                      radius:(CGFloat)radius
                       angle:(CGFloat)angleDegrees;
-(CGFloat)angleWithCenter:(CGPoint)center;

- (void)jump;
- (void)punchLeft;
- (void)punchRight;

- (void)updateAnimations;
- (void)updateDecisionsWithOldBarAngle:(CGFloat)oldBarAngle
                           newBarAngle:(CGFloat)newBarAngle
                           trackCenter:(CGPoint)trackCenter
                           trackRadius:(CGFloat)trackRadius;

- (void)makeInvincibleForSeconds:(CGFloat)seconds;

@end
