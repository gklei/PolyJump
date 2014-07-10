//
//  PJPlayLabelNode.m
//  PolyJump
//
//  Created by Gregory Klein on 7/9/14.
//  Copyright (c) 2014 Free the Robots. All rights reserved.
//

#import "PJPlayLabelNode.h"

@implementation PJPlayLabelNode

+ (instancetype)playLabelNode
{
   PJPlayLabelNode* playLabelNode = [PJPlayLabelNode labelNodeWithFontNamed:@"Futura-Medium"];
   playLabelNode.fontSize = 24;
   playLabelNode.fontColor = [SKColor blackColor];
   playLabelNode.text = @"Play!";
   playLabelNode.userInteractionEnabled = YES;

   return playLabelNode;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
   self.fontColor = [SKColor blackColor];
   if (self.touchEndedHandler)
   {
      self.touchEndedHandler();
   }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
   self.fontColor = [SKColor redColor];
}

@end
