//
//  PlayerNode.m
//  PolyJump
//
//  Created by David Cheng on 7/9/14.
//  Copyright (c) 2014 Free the Robots. All rights reserved.
//

#import "PlayerNode.h"
#import "SpineImport.h"

@interface PlayerNode()

@property(nonatomic) SGG_Spine* spineNode;
@property(nonatomic, weak) id<PJGameMetricProvider> gameMetricProvider;
@property(nonatomic) BOOL isOnTrack;
@end

@implementation PlayerNode

+(PlayerNode *)playerNodeWithGameMetricProvider:(id<PJGameMetricProvider>)gameMetricProvider
{
   return [[PlayerNode alloc] initWithGameMetricProvider:gameMetricProvider];
}

+(PlayerNode *)node
{
   NSParameterAssert(NO);  // use gamemetric provider instead
   return [[PlayerNode alloc] init];
}

- (instancetype)initWithGameMetricProvider:(id<PJGameMetricProvider>)gameMetricProvider
{
   self = [super init];
   if (self)
   {
      self.isOnTrack = NO;
      self.gameMetricProvider = gameMetricProvider;
      self.spineNode = [SGG_Spine node];
      [self.spineNode skeletonFromFileNamed:@"skeleton" andAtlasNamed:@"skeleton" andUseSkinNamed:Nil];
      self.spineNode.xScale = 0.4;
      self.spineNode.yScale = 0.4;
      [self addChild:self.spineNode];
   }
   return self;
}

#pragma mark - Property Overrides

- (BOOL)isIdle
{
   return self.state == PlayerStateIdle;
}

- (BOOL)isPunchingLeft
{
   return self.state == PlayerStatePunchingLeft;
}

- (BOOL)isPunchingRight
{
   return self.state == PlayerStatePunchingRight;
}

- (BOOL)isJumping
{
   return self.state == PlayerStateJumping;
}

- (CGFloat)angleOnTrack
{
   CGPoint trackCenter = self.gameMetricProvider.trackCenter;
   return atan2f(self.position.y - trackCenter.y, self.position.x - trackCenter.x);
}

- (CGPoint)positionOnTrackWithAngle:(CGFloat)angleOnTrack
{
   CGPoint trackCenter = self.gameMetricProvider.trackCenter;
   CGFloat trackRadius = self.isOnTrack ? self.gameMetricProvider.trackRadius : self.gameMetricProvider.preparingTrackRadius;
   return CGPointMake(trackCenter.x + trackRadius * cos(angleOnTrack),
                      trackCenter.y + trackRadius * sin(angleOnTrack));
}

- (void)setAngleOnTrack:(CGFloat)angleOnTrack
{
   self.position = [self positionOnTrackWithAngle:angleOnTrack];
   self.zRotation = angleOnTrack + M_PI/2;
}

-(CGFloat)angleWithCenter:(CGPoint)center
{
   return atan2f(self.position.y - center.y, self.position.x - center.x);
}

- (void)jumpOnTrackAndStartPlayingWithCompletionHandler:(dispatch_block_t)completionHandler
{
   self.isOnTrack = YES;
   
   CGPoint newTrackPosition = [self positionOnTrackWithAngle:self.angleOnTrack];
   
   SKAction* jumpUpAction = [SKAction moveByX:0 y:50 duration:0.2];
   SKAction* jumpDownAction = [SKAction moveTo:newTrackPosition duration:0.2];
   jumpUpAction.timingMode = SKActionTimingEaseOut;
   jumpDownAction.timingMode = SKActionTimingEaseIn;
   [self runAction:[SKAction sequence:@[jumpUpAction, jumpDownAction]] completion:completionHandler];
}


- (void)jump
{
   if ( self.state != PlayerStateIdle )
      return;
   
   SKAction* jumpUpAction = [SKAction moveByX:0 y:50 duration:0.2];
   SKAction* jumpDownAction = [SKAction moveByX:0 y:-50 duration:0.2];
   jumpUpAction.timingMode = SKActionTimingEaseOut;
   jumpDownAction.timingMode = SKActionTimingEaseIn;
   
   SKAction* jumpAction = [SKAction sequence:@[jumpUpAction, jumpDownAction]];
   
   self.state = PlayerStateJumping;
   [self.spineNode runAction:jumpAction completion:^{
      self.state = PlayerStateIdle;
   }];
}

- (void)punchLeft
{
   if ( self.state != PlayerStateIdle )
      return;

   [self.spineNode runAnimation:@"leftPunch" andCount:0 withIntroPeriodOf:0.0 andUseQueue:NO];
   
   self.state = PlayerStatePunchingLeft;
   dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      [self.spineNode resetSkeleton];
      self.state = PlayerStateIdle;
   });
}

- (void)punchRight
{
   if ( self.state != PlayerStateIdle )
      return;

   [self.spineNode runAnimation:@"rightPunch" andCount:0 withIntroPeriodOf:0.0 andUseQueue:NO];

   self.state = PlayerStatePunchingRight;
   dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      [self.spineNode resetSkeleton];
      self.state = PlayerStateIdle;
   });
}

- (void)updateAnimations
{
   [self.spineNode activateAnimations];
}

- (void)updateDecisionsWithOldBarAngle:(CGFloat)oldBarAngle
                           newBarAngle:(CGFloat)newBarAngle
                           trackCenter:(CGPoint)trackCenter
                           trackRadius:(CGFloat)trackRadius
{
   // Implement AI in subclass
}

- (void)makeInvincibleForSeconds:(CGFloat)seconds
{
   self.invincible = YES;
   dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      self.invincible = NO;
   });
}

@end
