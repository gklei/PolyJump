//
//  AIPlayerNode.m
//  PolyJump
//
//  Created by David Cheng on 7/19/14.
//  Copyright (c) 2014 Free the Robots. All rights reserved.
//

#import "AIPlayerNode.h"

static CGFloat radiansFromDegrees(CGFloat degrees)
{
   return (degrees*2*M_PI)/360;
}

static CGFloat normalize(CGFloat angle)
{
   while(angle<0)
      angle += 2*M_PI;
   return fmodf(angle, 2*M_PI);
}

static void normalizeRange(CGFloat * start, CGFloat * end)
{
   CGFloat oldStart = *start;
   *start = normalize(*start);
   CGFloat normalizeDelta = *start - oldStart;
   *end = *end + normalizeDelta;
}

static bool angleInRange(CGFloat angle, CGFloat angleStart, CGFloat angleEnd)
{
   return (angle >= angleStart && angle < angleEnd) ||
   (angle < angleStart && angle >= angleEnd);
   
}

@implementation AIPlayerNode

+(AIPlayerNode *)node
{
   return [[AIPlayerNode alloc] init];
}


- (void)updateDecisionsWithOldBarAngle:(CGFloat)oldBarAngle
                           newBarAngle:(CGFloat)newBarAngle
                           trackCenter:(CGPoint)trackCenter
                           trackRadius:(CGFloat)trackRadius
{
   CGFloat angleOnTrack = normalize([self angleWithCenter:trackCenter]);
   CGFloat deltaBarAngle = newBarAngle - oldBarAngle;
   CGFloat barDirectionMultiplier = deltaBarAngle > 0 ? 1 : -1;
   if ( angleOnTrack )
   {
      CGFloat startOffset = rand() % 20;
      CGFloat lookAheadStart = oldBarAngle + radiansFromDegrees(barDirectionMultiplier * startOffset);
      CGFloat endOffset = -5 + (rand() % 100*self.difficulty);
      CGFloat lookAheadEnd = newBarAngle + radiansFromDegrees(barDirectionMultiplier * endOffset);
      normalizeRange(&lookAheadStart, &lookAheadEnd);
      if ( angleInRange(angleOnTrack, lookAheadStart, lookAheadEnd) )
      {
         BOOL toTheLeft = deltaBarAngle > 0;
         [self doSomethingRandomly:toTheLeft];
      }
   }
}

- (void)doSomethingRandomly:(BOOL)toTheLeft
{
   int r = rand() % 2;
   switch( r )
   {
      case 0:
         [self jump];
         break;
      case 1:
         toTheLeft ? [self punchLeft] : [self punchRight];
         break;
   }
}

@end
