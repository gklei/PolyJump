//
//  PJGameScene.m
//  PolyJump
//
//  Created by Gregory Klein on 7/9/14.
//  Copyright (c) 2014 Free the Robots. All rights reserved.
//

#import "PJGameScene.h"
#import "DZSpineScene.h"
#import "DZSpineSceneBuilder.h"
#import "SpineSkeleton.h"
#import "PJBarNode.h"

@interface PJGameScene ()

@property (nonatomic, assign, readonly) CGPoint trackCenter;
@property (nonatomic, assign, readonly) CGFloat trackRadius;

@property (nonatomic, assign) NSTimeInterval lastTime;
@property (nonatomic) PJBarNode* barNode;

@property (nonatomic) SpineSkeleton* ninjaSkeleton;
@property (nonatomic) DZSpineSceneBuilder* builder;
@property (nonatomic) SKNode* ninja;
@property (nonatomic) SKNode* spineNode;

@end

@implementation PJGameScene

- (instancetype)initWithSize:(CGSize)size
{
   if (self = [super initWithSize:size])
   {
      self.backgroundColor = [SKColor colorWithWhite:.9 alpha:1];
      [self setupTrack];
      [self setupBar];

      // Currently Broken!
//      [self setupNinja];
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
   self.barNode = [PJBarNode nodeWithBarLength:self.trackRadius];
   self.barNode.position = self.trackCenter;
   
   [self addChild:self.barNode];
}

- (void)setupNinja
{
   self.ninjaSkeleton = [DZSpineSceneBuilder loadSkeletonName:@"skeleton" scale:0.5];
   self.builder = [DZSpineSceneBuilder builder];
   self.ninja = [SKNode node];
   self.ninja.position = CGPointMake(self.size.width/2, 0);

   [self addChild:self.ninja];
   self.spineNode = [_builder nodeWithSkeleton:self.ninjaSkeleton animationName:@"trip" loop:NO];
   [self.ninja addChild:_spineNode];
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
      [self.barNode updateWithDeltaTime:dt];
   }
   
   self.lastTime = currentTime;
}

@end
