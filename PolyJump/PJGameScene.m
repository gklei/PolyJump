//
//  PJGameScene.m
//  PolyJump
//
//  Created by Gregory Klein on 7/9/14.
//  Copyright (c) 2014 Free the Robots. All rights reserved.
//

#import "PJGameScene.h"

@interface PJGameScene ()

@property (nonatomic, assign, readonly) CGPoint trackCenter;
@property (nonatomic, assign, readonly) CGFloat trackRadius;

@property (nonatomic, assign) NSTimeInterval lastTime;

@end

@implementation PJGameScene

- (instancetype)initWithSize:(CGSize)size
{
   if (self = [super initWithSize:size])
   {
      self.backgroundColor = [SKColor colorWithWhite:.9 alpha:1];
      [self setupTrack];
      [self setupBar];
   }
   return self;
}

- (void)setupMainLabel
{
   self.backgroundColor = [SKColor colorWithWhite:.9 alpha:1.0];

   SKLabelNode *mainLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];

   mainLabel.fontColor = [SKColor blackColor];
   mainLabel.text = @"GAME";
   mainLabel.fontSize = 30;
   mainLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));

   [self addChild:mainLabel];
}

- (void)setupTrack
{
   SKShapeNode* track = [SKShapeNode node];
   CGRect trackRect = CGRectMake(-self.trackRadius, -self.trackRadius, self.trackRadius*2, self.trackRadius*2);
   trackRect = CGRectInset(trackRect, 50, 50);

   UIBezierPath* trackPath = [UIBezierPath bezierPathWithOvalInRect:trackRect];
   track.path = trackPath.CGPath;
   track.strokeColor = [SKColor blueColor];
   track.lineWidth = 50.f;
   track.antialiased = YES;
   track.position = self.trackCenter;

   [self addChild:track];
}

- (void)setupBar
{
   CGFloat barThickness = 10;
   CGRect rect = CGRectMake(0, -barThickness, self.trackRadius, barThickness);
   SKShapeNode* barNode = [SKShapeNode node];
   barNode.path = [UIBezierPath bezierPathWithRect:rect].CGPath;
   barNode.fillColor = [SKColor redColor];
   barNode.lineWidth = 0.0;
   barNode.position = self.trackCenter;
   barNode.zRotation = M_PI_4;
   [self addChild:barNode];
}

- (CGPoint)trackCenter
{
   CGFloat padding = 20;
   return CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) - self.trackRadius - padding);
}

- (CGFloat)trackRadius
{
   return CGRectGetWidth(self.frame)*.5;
}

- (void)update:(NSTimeInterval)currentTime
{
   if ( self.lastTime )
   {
      NSTimeInterval dt = currentTime - self.lastTime;
      NSLog(@"dt = %f", dt);
   }
   self.lastTime = currentTime;
}

@end
