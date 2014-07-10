//
//  PegNode.m
//  PolyJump
//
//  Created by David Cheng on 7/9/14.
//  Copyright (c) 2014 Free the Robots. All rights reserved.
//

#import "PegNode.h"

@implementation PegNode

+(PegNode *)node
{
   return [[PegNode alloc] init];
}

- (instancetype)init
{
   self = [super init];
   if (self)
   {
      CGFloat pegRadius = 10;
      CGRect pegRect = CGRectMake(-pegRadius, -pegRadius, pegRadius*2, pegRadius*2);
      self.path = [UIBezierPath bezierPathWithOvalInRect:pegRect].CGPath;
      self.fillColor = [UIColor purpleColor];
   }
   return self;
}

+(CGPoint)positionWithCenter:(CGPoint)center
                      radius:(CGFloat)radius
                       angle:(CGFloat)angleDegrees
{
   CGFloat angleRad = (angleDegrees*2*M_PI)/360;
   return CGPointMake(center.x + radius * cos(angleRad),
                                  center.y + radius * sin(angleRad));
   
}

-(CGFloat)angleWithCenter:(CGPoint)center
                   radius:(CGFloat)radius
{
   return atan2f(self.position.y - center.y, self.position.x - center.x);
}

@end
