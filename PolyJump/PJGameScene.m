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
#import "PegNode.h"
#import "PJButtonLabelNode.h"
#import "PJMainMenuScene.h"

static CGFloat normalize(CGFloat angle)
{
   while(angle<0)
      angle += 2*M_PI;
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

@property (nonatomic) NSInteger numHitPegs;

@end

@implementation PJGameScene

- (instancetype)initWithSize:(CGSize)size
{
   if (self = [super initWithSize:size])
   {
      self.backgroundColor = [SKColor colorWithWhite:.9 alpha:1];
      [self setupTrack];
      [self setupBar];
      [self addPeg];
      [self addPeg];
      [self addPeg];
      [self addPeg];

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

   UIBezierPath* trackPath = [UIBezierPath bezierPathWithOvalInRect:trackRect];
   track.path = trackPath.CGPath;
   track.strokeColor = [SKColor blueColor];
   track.lineWidth = self.frame.size.width/30;
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

- (void)addPeg
{
   PegNode* pegNode = [PegNode node];
   CGFloat angle = rand() % 360;
   pegNode.position = [PegNode positionWithCenter:self.trackCenter radius:self.trackRadius angle:angle];
   pegNode.name = @"enemy";
   [self addChild:pegNode];
}

- (void)setupNinja
{
   self.ninja = [SGG_Spine node];
   [self.ninja skeletonFromFileNamed:@"skeleton" andAtlasNamed:@"skeleton" andUseSkinNamed:Nil];
   self.ninja.position = CGPointMake(self.size.width/4, self.size.height/4);
//   self.ninja.queuedAnimation = @"leftPunch";
   self.ninja.queueIntro = 0.1;
   [self.ninja runAnimation:@"rightPunch" andCount:0 withIntroPeriodOf:0.1 andUseQueue:YES];
//   [self.ninja runAnimationSequence:@[@"leftPunch", @"rightPunch", @"leftPunch", @"rightPunch", @"leftPunch", @"rightPunch"] andUseQueue:NO];
   self.ninja.zPosition = 0;
   [self addChild:self.ninja];
}

- (CGPoint)trackCenter
{
   CGFloat padding = 20;
   return CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) - self.trackRadius - padding);
}

- (CGFloat)trackRadius
{
   return CGRectGetWidth(self.frame)*.5 - 25;
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

   [self.ninja activateAnimations];

   self.lastTime = currentTime;
}

-(void)hitTestWithOldBarAngle:(CGFloat)oldBarAngle newBarAngle:(CGFloat)newBarAngle
{
   CGFloat angleDelta = newBarAngle - oldBarAngle;
   CGFloat angleStart = normalize(oldBarAngle);
   CGFloat angleEnd   = angleStart + angleDelta;
   
   [self enumerateChildNodesWithName:@"enemy" usingBlock:^(SKNode *node, BOOL *stop) {
      PegNode* pegNode = (PegNode *)node;
      CGFloat testAngle = normalize([pegNode angleWithCenter:self.trackCenter radius:self.trackRadius]);
      if ( angleInRange(testAngle, angleStart, angleEnd) )
      {
//         NSLog(@"hit pegNode %@", pegNode);
         self.numHitPegs = self.numHitPegs + 1;
      }
   }];
   
   if ( self.numHitPegs > 3 )
      [self endGame];
}

-(void)endGame
{
   self.scene.view.paused = YES;
   
   SKSpriteNode* endColorNode = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithWhite:0.9 alpha:0.8] size:self.frame.size];
   endColorNode.anchorPoint = CGPointMake(0, 0);
   [self addChild:endColorNode];
   
   PJButtonLabelNode* retryButton = [PJButtonLabelNode nodeWithText:@"Retry"];
   retryButton.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
   retryButton.touchEndedHandler = ^{
      self.scene.view.paused = NO;
      [self.scene.view presentScene:[[PJGameScene alloc] initWithSize:self.frame.size]];
   };
   [self addChild:retryButton];
   
   PJButtonLabelNode* quitButton = [PJButtonLabelNode nodeWithText:@"Quit"];
   quitButton.position = CGPointMake(retryButton.position.x, retryButton.position.y - 100);
   quitButton.touchEndedHandler = ^{
      self.scene.view.paused = NO;
      SKScene * scene = [PJMainMenuScene sceneWithSize:self.view.bounds.size];
      scene.scaleMode = SKSceneScaleModeAspectFill;
      [self.view presentScene:scene];
   };
   [self addChild:quitButton];
}

@end
