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

@end

@implementation PlayerNode

+(PlayerNode *)node
{
   return [[PlayerNode alloc] init];
}

- (instancetype)init
{
   self = [super init];
   if (self)
   {
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

+(CGPoint)positionWithCenter:(CGPoint)center
                      radius:(CGFloat)radius
                       angle:(CGFloat)angleRadians
{
//   CGFloat angleRad = (angleDegrees*2*M_PI)/360;
   return CGPointMake(center.x + radius * cos(angleRadians),
                                  center.y + radius * sin(angleRadians));
   
}

-(CGFloat)angleWithCenter:(CGPoint)center
                   radius:(CGFloat)radius
{
   return atan2f(self.position.y - center.y, self.position.x - center.x);
}

- (void)jump
{
   SKAction* jumpUpAction = [SKAction moveByX:0 y:50 duration:0.2];
   SKAction* jumpDownAction = [SKAction moveByX:0 y:-50 duration:0.2];
   jumpUpAction.timingMode = SKActionTimingEaseOut;
   jumpDownAction.timingMode = SKActionTimingEaseIn;
   
   SKAction* jumpAction = [SKAction sequence:@[jumpUpAction, jumpDownAction]];
   [self.spineNode runAction:jumpAction];
}

- (void)punchLeft
{
   [self.spineNode runAnimation:@"leftPunch" andCount:0 withIntroPeriodOf:0.0 andUseQueue:NO];
}

- (void)punchRight
{
   [self.spineNode runAnimation:@"rightPunch" andCount:0 withIntroPeriodOf:0.0 andUseQueue:NO];
}

- (void)update
{
   [self.spineNode activateAnimations];
}


@end
