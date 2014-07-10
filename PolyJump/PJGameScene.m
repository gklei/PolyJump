//
//  PJGameScene.m
//  PolyJump
//
//  Created by Gregory Klein on 7/9/14.
//  Copyright (c) 2014 Free the Robots. All rights reserved.
//

#import "PJGameScene.h"
#import "PJBarNode.h"
#import "SpineImport.h"

static CGFloat normalize(CGFloat angle)
{
   return fmodf(angle, 2*M_PI);
}

static bool angleInRange(CGFloat angle, CGFloat angleStart, CGFloat angleEnd)
{
   return (angle >= angleStart && angle < angleEnd) ||
          (angle < angleStart && angle >= angleEnd);
   
}

@interface PJGameScene ()

@property (nonatomic, assign, readonly) CGPoint trackCenter;
@property (nonatomic, assign, readonly) CGFloat trackRadius;

@property (nonatomic, assign) NSTimeInterval lastTime;
@property (nonatomic) PJBarNode* barNode;
@property (nonatomic) SGG_Spine* ninja;

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
      [self setupNinja];
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
   self.ninja = [SGG_Spine node];
   [self.ninja skeletonFromFileNamed:@"skeleton" andAtlasNamed:@"skeleton" andUseSkinNamed:Nil];
   self.ninja.position = CGPointMake(self.size.width/4, self.size.height/4);
//   self.ninja.queuedAnimation = @"leftPunch";
   self.ninja.queueIntro = 0.1;
//   [self.ninja runAnimation:@"rightPunch" andCount:0 withIntroPeriodOf:0.1 andUseQueue:YES];
   [self.ninja runAnimationSequence:@[@"leftPunch", @"rightPunch", @"leftPunch", @"rightPunch"] andUseQueue:YES];
   self.ninja.zPosition = 0;
   [self addChild:self.ninja];
   /*
   boy = [SGG_Spine node];
   [boy skeletonFromFileNamed:@"spineboy" andAtlasNamed:@"spineboy" andUseSkinNamed:Nil];
   boy.position = CGPointMake(self.size.width/4, self.size.height/4);
   boy.queuedAnimation = @"walk";
   boy.queueIntro = 0.1;
   [boy runAnimation:@"walk" andCount:0 withIntroPeriodOf:0.1 andUseQueue:YES];
   boy.zPosition = 0;
   [self addChild:boy];
    */
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
      CGFloat oldBarAngle = self.barNode.zRotation;
      [self.barNode updateWithDeltaTime:dt];
      [self hitTestWithOldBarAngle:oldBarAngle newBarAngle:self.barNode.zRotation];
   }

   self.lastTime = currentTime;
}

-(void)hitTestWithOldBarAngle:(CGFloat)oldBarAngle newBarAngle:(CGFloat)newBarAngle
{
#pragma warning Test against the players
   CGFloat angleDelta = newBarAngle - oldBarAngle;
   CGFloat angleStart = normalize(oldBarAngle);
   CGFloat angleEnd   = angleStart + angleDelta;
   
   CGFloat testAngle = M_PI/4;
   if ( angleInRange(testAngle, angleStart, angleEnd) )
   {
      NSLog(@"hit %f", testAngle);
   }
   
}

@end
