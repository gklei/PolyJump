//
//  PJBarNode.m
//  PolyJump
//
//  Created by David Cheng on 7/9/14.
//  Copyright (c) 2014 Free the Robots. All rights reserved.
//

#import "PJBarNode.h"

@interface PJBarNode()

@property(nonatomic) CGFloat velocity;
@property(nonatomic) CGFloat extraSpeedApplied;

@end

@implementation PJBarNode

+(PJBarNode *)nodeWithBarLength:(CGFloat)barLength
{
   return [[PJBarNode alloc] initWithBarLength:barLength];
}

- (instancetype)initWithBarLength:(CGFloat)barLength
{
   self = [super init];
   if (self)
   {
      CGFloat barThickness = 10;
      CGRect rect = CGRectMake(0, -barThickness/2, barLength, barThickness);
      self.path = [UIBezierPath bezierPathWithRect:rect].CGPath;
      self.fillColor = [SKColor redColor];
      self.lineWidth = 0.0;
      self.zRotation = -M_PI/4;
      self.isAccelerating = NO;
      
      self.velocity = 3;
   }
   return self;
}


-(void)updateWithDeltaTime:(NSTimeInterval)deltaTime
{
   [self dampenExtraVelocityWithDeltaTime:deltaTime];
   self.zRotation = self.zRotation + self.velocity*deltaTime;
   if ( self.isAccelerating )
      self.velocity = MIN(self.velocity*1.0005, 8);
}

-(void)addSpeed:(CGFloat)speed
{
   if ( self.velocity > 0 )
   {
      self.velocity = self.velocity + speed;
   }
   else
   {
      self.velocity = self.velocity - speed;
   }
}

-(void)reverseDirectionWithExtraHitPower:(CGFloat)extraHitPower
{
   CGFloat extraSpeed = extraHitPower * 4;
   [self addSpeed:extraSpeed];
   self.extraSpeedApplied = extraSpeed;

   self.velocity = -self.velocity;
}

- (void)dampenExtraVelocityWithDeltaTime:(NSTimeInterval)deltaTime
{
   if ( self.extraSpeedApplied > 0 )
   {
      CGFloat speedToDampenPerSecond = 2;
      CGFloat speedToDampen = speedToDampenPerSecond * deltaTime;
      CGFloat clampedSpeedToDampen = MIN( speedToDampen, self.extraSpeedApplied );
      
      self.extraSpeedApplied = self.extraSpeedApplied - clampedSpeedToDampen;
      [self addSpeed:-clampedSpeedToDampen];
   }
}

@end
