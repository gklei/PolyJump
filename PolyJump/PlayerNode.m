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
@property(nonatomic) SKShapeNode* powerSwipeNode;
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
      
      self.powerSwipeNode = [SKShapeNode node];
      CGFloat radius = 20;
      CGRect rect = CGRectMake(-radius, -radius, radius*2, radius*2);
      
      UIBezierPath* trackPath = [UIBezierPath bezierPathWithOvalInRect:rect];
      self.powerSwipeNode.path = trackPath.CGPath;
      self.powerSwipeNode.fillColor = [SKColor purpleColor];
      self.powerSwipeNode.antialiased = YES;
      self.powerSwipeNode.alpha = 0;
      [self addChild:self.powerSwipeNode];

      
      self.spineNode = [SGG_Spine node];
      [self.spineNode skeletonFromFileNamed:@"skeleton" andAtlasNamed:@"skeleton" andUseSkinNamed:Nil];
      self.spineNode.xScale = 0.3;
      self.spineNode.yScale = 0.3;
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

   self.extraHitPower = 0;
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

   self.extraHitPower = 0;
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

- (void)incrementHitPowerWithDelta:(CGFloat)delta
{
   self.extraHitPower = self.extraHitPower + delta;
}

- (void)resetHitPower
{
   self.extraHitPower = 0;
}

- (void)setExtraHitPower:(CGFloat)extraHitPower
{
   _extraHitPower = extraHitPower;
   if ( _extraHitPower > 0 )
   {
      CGFloat extraPower = extraHitPower;
      CGFloat scale = 0.001 + extraPower;
      self.powerSwipeNode.xScale = scale;
      self.powerSwipeNode.yScale = scale;
      self.powerSwipeNode.alpha = 1;
   }
   else
   {
      [self.powerSwipeNode runAction:[SKAction fadeAlphaTo:0 duration:0.2]];
   }
}
@end
