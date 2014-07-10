//
//  PJMainMenuScene.m
//  PolyJump
//
//  Created by Gregory Klein on 7/9/14.
//  Copyright (c) 2014 Free the Robots. All rights reserved.
//

#import "PJMainMenuScene.h"
#import "PJGameScene.h"
#import "PJPlayLabelNode.h"

@implementation PJMainMenuScene

- (instancetype)initWithSize:(CGSize)size
{
   if (self = [super initWithSize:size])
   {
      [self setupMainLabel];
      [self setupPlayLabel];
   }
   return self;
}

- (void)setupMainLabel
{
   self.backgroundColor = [SKColor colorWithWhite:.9 alpha:1.0];

   SKLabelNode *mainLabel = [SKLabelNode labelNodeWithFontNamed:@"Futura-Medium"];

   mainLabel.fontColor = [SKColor blackColor];
   mainLabel.text = @"Poly Jump";
   mainLabel.fontSize = 30;
   mainLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));

   [self addChild:mainLabel];
}

- (void)setupPlayLabel
{
   PJPlayLabelNode* playLabel = [PJPlayLabelNode playLabelNode];
   playLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame)*.25);
   playLabel.touchEndedHandler = ^{
      [self.scene.view presentScene:[[PJGameScene alloc] initWithSize:self.frame.size]
                         transition:[SKTransition fadeWithDuration:.5]];
   };
   [self addChild:playLabel];
}

@end
