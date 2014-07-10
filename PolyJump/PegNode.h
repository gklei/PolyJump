//
//  PegNode.h
//  PolyJump
//
//  Created by David Cheng on 7/9/14.
//  Copyright (c) 2014 Free the Robots. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface PegNode : SKShapeNode

+(PegNode *)node;

+(CGPoint)positionWithCenter:(CGPoint)center
                      radius:(CGFloat)radius
                       angle:(CGFloat)angleDegrees;
-(CGFloat)angleWithCenter:(CGPoint)center
                   radius:(CGFloat)radius;
@end
