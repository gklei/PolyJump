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
#import "PlayerNode.h"
#import "AIPlayerNode.h"
#import "PJButtonLabelNode.h"
#import "PJMainMenuScene.h"
#import "UIGestureRecognizer+BlocksKit.h"

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

static bool angleInRange(CGFloat angle, CGFloat angleStart, CGFloat angleEnd)
{
   return (angle >= angleStart && angle < angleEnd) ||
          (angle < angleStart && angle >= angleEnd);
   
}

@interface PJGameScene () <UIGestureRecognizerDelegate>

@property (nonatomic, assign, readonly) CGPoint ninjaCenter;
@property (nonatomic, assign, readonly) CGPoint trackCenter;
@property (nonatomic, assign, readonly) CGFloat trackRadius;

@property (nonatomic, assign) NSTimeInterval lastTime;
@property (nonatomic) PJBarNode* barNode;
@property (nonatomic) PlayerNode* controlledPlayerNode;

@property (nonatomic) UITapGestureRecognizer* tapRecognizer;
@property (nonatomic) UISwipeGestureRecognizer* leftSwipeRecognizer;
@property (nonatomic) UISwipeGestureRecognizer* rightSwipeRecognizer;
@property (nonatomic) UISwipeGestureRecognizer* upSwipeRecognizer;

@property (nonatomic) NSInteger numHitPegs;
@property (nonatomic) NSInteger numEnemiesLeft;

@end

@implementation PJGameScene

- (instancetype)initWithSize:(CGSize)size
{
   if (self = [super initWithSize:size])
   {
      self.backgroundColor = [SKColor colorWithWhite:.9 alpha:1];
      [self setupTrack];
      [self setupBar];
      [self addBadGuy];
      [self addBadGuy];
      [self addBadGuy];
      [self addBadGuy];

      [self setupNinja];
   }
   return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
   return YES;
}

- (void)addGestureRecognizersToView:(SKView *)view
{
   self.leftSwipeRecognizer = [UISwipeGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
      [self.controlledPlayerNode punchLeft];
   }];

   self.rightSwipeRecognizer = [UISwipeGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
      [self.controlledPlayerNode punchRight];
   }];
   
   self.upSwipeRecognizer = [UISwipeGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
      [self.controlledPlayerNode jump];
   }];

   self.tapRecognizer = [UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location)
                         {
                            NSLog(@"tap");
                         }];

   self.leftSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
   self.rightSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
   self.upSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionUp;

   self.leftSwipeRecognizer.delegate = self;
   self.rightSwipeRecognizer.delegate = self;
   self.upSwipeRecognizer.delegate = self;
   self.tapRecognizer.delegate = self;

   [view addGestureRecognizer:self.leftSwipeRecognizer];
   [view addGestureRecognizer:self.rightSwipeRecognizer];
   [view addGestureRecognizer:self.upSwipeRecognizer];
   [view addGestureRecognizer:self.tapRecognizer];
}

- (void)removeGestureRecognizers
{
   [self.view removeGestureRecognizer:self.leftSwipeRecognizer];
   [self.view removeGestureRecognizer:self.rightSwipeRecognizer];
   [self.view removeGestureRecognizer:self.upSwipeRecognizer];
   [self.view removeGestureRecognizer:self.tapRecognizer];
}

- (void)didMoveToView:(SKView *)view
{
   [self addGestureRecognizersToView:view];
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

- (void)addBadGuy
{
   AIPlayerNode* playerNode = [AIPlayerNode node];
   CGFloat angleOnTrackDegrees = rand() % 360;
   CGFloat angleOnTrackRadians = radiansFromDegrees(angleOnTrackDegrees);
   playerNode.position = [PlayerNode positionWithCenter:self.trackCenter radius:self.trackRadius angle:angleOnTrackRadians];
   playerNode.name = @"player";
   playerNode.zRotation = angleOnTrackRadians + M_PI/2;
   [self addChild:playerNode];
}

- (void)setupNinja
{
   self.controlledPlayerNode = [PlayerNode node];
   self.controlledPlayerNode.position = self.ninjaCenter;
   self.controlledPlayerNode.name = @"player";
   [self addChild:self.controlledPlayerNode];
}

#pragma mark - Property Overrides
- (CGPoint)ninjaCenter
{
   return CGPointMake(self.trackCenter.x, self.trackCenter.y - self.trackRadius);
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

- (NSInteger)numEnemiesLeft
{
   __block int enemiesLeft = 0;
   [self enumerateChildNodesWithName:@"player" usingBlock:^(SKNode *node, BOOL *stop) {
      if ( node != self.controlledPlayerNode )
         enemiesLeft++;
   }];
   return enemiesLeft;
}


- (void)update:(NSTimeInterval)currentTime
{
   [self updatePlayers];

   if ( self.lastTime )
   {
      NSTimeInterval dt = currentTime - self.lastTime;
      CGFloat oldBarAngle = self.barNode.zRotation;
      [self.barNode updateWithDeltaTime:dt];
      CGFloat newBarAngle = self.barNode.zRotation;
      
      [self hitTestWithOldBarAngle:oldBarAngle newBarAngle:newBarAngle];
      
      [self updateDecisionsWithOldBarAngle:oldBarAngle newBarAngle:newBarAngle];
   }
   
   [self checkForEndGame];

   self.lastTime = currentTime;
}

- (void)updatePlayers
{
   [self enumerateChildNodesWithName:@"player" usingBlock:^(SKNode *node, BOOL *stop) {
      PlayerNode* playerNode = (PlayerNode *)node;
      [playerNode updateAnimations];
   }];
}

- (void)updateDecisionsWithOldBarAngle:(CGFloat)oldBarAngle newBarAngle:(CGFloat)newBarAngle
{
   [self enumerateChildNodesWithName:@"player" usingBlock:^(SKNode *node, BOOL *stop) {
      PlayerNode* playerNode = (PlayerNode *)node;
      [playerNode updateDecisionsWithOldBarAngle:oldBarAngle
                                     newBarAngle:newBarAngle
                                     trackCenter:self.trackCenter
                                     trackRadius:self.trackRadius];
   }];
}

-(void)hitTestWithOldBarAngle:(CGFloat)oldBarAngle newBarAngle:(CGFloat)newBarAngle
{
   CGFloat angleDelta = newBarAngle - oldBarAngle;
   CGFloat angleStart = normalize(oldBarAngle);
   CGFloat angleEnd   = angleStart + angleDelta;
   
   [self enumerateChildNodesWithName:@"player" usingBlock:^(SKNode *node, BOOL *stop) {
      
      PlayerNode* playerNode = (PlayerNode *)node;
      CGFloat testAngle = normalize([playerNode angleWithCenter:self.trackCenter radius:self.trackRadius]);
      if ( angleInRange(testAngle, angleStart, angleEnd) )
      {
         if ( (playerNode.isPunchingLeft && angleDelta > 0) ||
              (playerNode.isPunchingRight && angleDelta < 0) )
         {
            [self.barNode reverseDirection];
            [playerNode makeInvincibleForSeconds:1/30.0f]; // Necessary because the bar will still be hitting the player the next frame
         }
         else if ( playerNode.isJumping )
         {
         }
         else
         {
            if ( !playerNode.invincible )
            {
               playerNode.state = PlayerStateDead;
               [playerNode removeFromParent];
               self.numHitPegs = self.numHitPegs + 1;
            }
         }
      }
   }];
   
//   if ( self.numHitPegs > 3 )
//      [self endGame];
}

-(void)checkForEndGame
{
   if ( self.controlledPlayerNode.state == PlayerStateDead )
   {
      [self endGame:NO];
   }
   
   
   if ( self.numEnemiesLeft == 0 )
   {
      [self endGame:YES];
   }
}


-(void)endGame:(BOOL)win
{
   self.scene.view.paused = YES;
   [self removeGestureRecognizers];
   
   SKSpriteNode* endColorNode = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithWhite:0.9 alpha:0.8] size:self.frame.size];
   endColorNode.anchorPoint = CGPointMake(0, 0);
   endColorNode.zPosition = 1;
   [self addChild:endColorNode];
   
   PJButtonLabelNode* retryButton = [PJButtonLabelNode nodeWithText:@"Retry"];
   retryButton.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
   retryButton.zPosition = 2;
   retryButton.touchEndedHandler = ^{
      self.scene.view.paused = NO;
      [self.scene.view presentScene:[[PJGameScene alloc] initWithSize:self.frame.size]];
   };
   [self addChild:retryButton];
   
   PJButtonLabelNode* quitButton = [PJButtonLabelNode nodeWithText:@"Quit"];
   quitButton.position = CGPointMake(retryButton.position.x, retryButton.position.y - 100);
   quitButton.zPosition = 2;
   quitButton.touchEndedHandler = ^{
      self.scene.view.paused = NO;
      SKScene * scene = [PJMainMenuScene sceneWithSize:self.view.bounds.size];
      scene.scaleMode = SKSceneScaleModeAspectFill;
      [self.view presentScene:scene];
   };
   [self addChild:quitButton];
}

@end
