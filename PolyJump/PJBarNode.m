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
   self.zRotation = self.zRotation + self.velocity*deltaTime;
   if ( self.isAccelerating )
      self.velocity = MIN(self.velocity*1.0005, 8);
}

-(void)reverseDirection
{
   self.velocity = -self.velocity;
}

@end
