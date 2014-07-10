//
//  PJBarNode.m
//  PolyJump
//
//  Created by David Cheng on 7/9/14.
//  Copyright (c) 2014 Free the Robots. All rights reserved.
//

#import "PJBarNode.h"

@implementation PJBarNode

+(PJBarNode *)nodeWithBarLength:(CGFloat)barLength
{
   CGFloat barThickness = 10;
   CGRect rect = CGRectMake(0, -barThickness, barLength, barThickness);
   PJBarNode* barNode = [PJBarNode node];
   barNode.path = [UIBezierPath bezierPathWithRect:rect].CGPath;
   barNode.fillColor = [SKColor redColor];
   barNode.lineWidth = 0.0;
   barNode.zRotation = M_PI_4;
   return barNode;
}

@end
