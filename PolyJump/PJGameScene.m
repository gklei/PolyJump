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
#import "SKScene+nodesWithName.h"
#import "PJButtonLabelNode.h"

static NSString* s_inGamePlayerName = @"player";
static NSString* s_preparingPlayerName = @"preparingPlayer";

static CGFloat radiansFromDegrees(CGFloat degrees)
{
   return (degrees*2*M_PI)/360;
}

static CGFloat degreesFromRadians(CGFloat radians)
{
   return 360*radians / (2*M_PI);
}

static CGFloat normalize(CGFloat angle)
{
   while(angle<0)
      angle += 2*M_PI;
   return fmodf(angle, 2*M_PI);
}

static CGFloat normalizeDegrees(CGFloat angle)
{
   while(angle<0)
      angle += 360;
   return fmodf(angle, 360);
}

static bool angleInRange(CGFloat angle, CGFloat angleStart, CGFloat angleEnd)
{
   return (angle >= angleStart && angle < angleEnd) ||
          (angle < angleStart && angle >= angleEnd);
   
}

@interface PJGameScene () <UIGestureRecognizerDelegate>

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
@property (nonatomic) NSInteger numPreparingEnemies;


@property (nonatomic) NSInteger currentLevelNumber;
@property (nonatomic) BOOL settingUpNextLevel;

@property (nonatomic) BOOL isPlaying;

@property (nonatomic) NSTimeInterval totalGameTime;

@end

@implementation PJGameScene

- (instancetype)initWithSize:(CGSize)size
{
   if (self = [super initWithSize:size])
   {
      self.backgroundColor = [SKColor colorWithWhite:.9 alpha:1];
      
      [self setupPauseButton];
      [self setupInstructions];
      [self setupTrack];
      [self setupBar];
      [self setupNinja];
      
      self.currentLevelNumber = 0;
      
      self.isPlaying = NO;
   }
   return self;
}

- (void)setupPauseButton
{
   PJButtonLabelNode* buttonNode = [PJButtonLabelNode nodeWithText:@"Pause"];
   buttonNode.position = CGPointMake(CGRectGetMaxX(self.frame) - 40, 20);
   
   __weak typeof(self) weakSelf = self;
   __weak PJButtonLabelNode* weakButtonNode = buttonNode;
   buttonNode.touchEndedHandler = ^{
      self.scene.view.paused = !self.scene.view.paused;
      weakButtonNode.text = weakSelf.scene.view.paused ? @"Resume" : @"Pause";
      self.lastTime = 0;
   };
   [self addChild:buttonNode];
}

- (void)setupInstructions
{
   SKLabelNode* labelNode = [SKLabelNode labelNodeWithFontNamed:@"Futura-Medium"];
   labelNode.fontSize = 24;
   labelNode.fontColor = [SKColor blackColor];
   labelNode.text = @"Swipe up to play";
   labelNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - 100);
   labelNode.name = @"instructions";
   [self addChild:labelNode];
}

- (NSArray *)inGamePlayerNodes
{
   return [self nodesWithName:s_inGamePlayerName];
}

- (NSArray *)preparingPlayerNodes
{
   return [self nodesWithName:s_preparingPlayerName];
}

- (NSArray *)allPlayerNodes
{
   return [[self preparingPlayerNodes] arrayByAddingObjectsFromArray:[self inGamePlayerNodes]];
}

- (NSArray *)allPlayerNodeAngles
{
   NSMutableArray* angles = [NSMutableArray array];
   NSArray* playerNodes = [self allPlayerNodes];
   for( PlayerNode* playerNode in playerNodes )
   {
      CGFloat angle = [playerNode angleWithCenter:self.trackCenter];
      [angles addObject:@(angle)];
   }
   return angles;
}


- (CGFloat)newAIPlayerAngle
{
   NSArray* existingAngles = [self allPlayerNodeAngles];
   CGFloat angle;
   BOOL spacedOutEnough;
   do
   {
      angle = normalizeDegrees(-45 + rand()%270);
      spacedOutEnough = YES;
      for( NSNumber* existingAngleNumber in existingAngles )
      {
         CGFloat existingAngle = degreesFromRadians(normalize([existingAngleNumber floatValue]));
         if ( abs(existingAngle - angle ) < 30 ||
              abs(existingAngle+360 - angle) < 30 ||
              abs(existingAngle - (angle+360)) < 30 )
         {
            spacedOutEnough = NO;
            break;
         }
      }
   }
   while( !spacedOutEnough );
   return angle;
}

- (void)setupLevel:(NSInteger)levelNumber
{
   NSMutableArray* aiPlayerNodesToAdd = [NSMutableArray array];
   PlayerNode* newNode;
   switch ( levelNumber )
   {
      case 1:
         newNode = [self aiPlayerNodeWithDifficulty:0.1 atTrackAngleInDegrees:90];
         [aiPlayerNodesToAdd addObject:newNode];
         [self addChild:newNode];
         break;
      case 2:
         for( int angle = 45; angle <= 135; angle += 90 )
         {
            newNode = [self aiPlayerNodeWithDifficulty:0.3 atTrackAngleInDegrees:angle];
            [aiPlayerNodesToAdd addObject:newNode];
            [self addChild:newNode];
         }
         break;
      case 3:
         for( int angle = 55; angle <= 125; angle += 35 )
         {
            newNode = [self aiPlayerNodeWithDifficulty:0.5 atTrackAngleInDegrees:angle];
            [aiPlayerNodesToAdd addObject:newNode];
            [self addChild:newNode];
         }
         break;
      default:
         for( int i = 0; i < 4; i++ )
         {
            // newAIPlayerAngle checks previous nodes so we need to add the child node before we call newAIPlayerAngle again
            newNode = [self aiPlayerNodeWithDifficulty:0.8 atTrackAngleInDegrees:[self newAIPlayerAngle]];
            [aiPlayerNodesToAdd addObject:newNode];
            [self addChild:newNode];
         }
   }
   
   for( AIPlayerNode* aiPlayerNode in aiPlayerNodesToAdd)
   {
      aiPlayerNode.alpha = 0;
      [aiPlayerNode runAction:[SKAction fadeInWithDuration:0.3]];
      CGFloat delay = 1.5 + (rand()%10)/10.0;  // 1.5-2.5
      [self queuePlayerNodeForPlaying:aiPlayerNode withDelay:delay];
   }
}

- (void)preparePlayerNode:(PlayerNode *)playerNode atAngleInDegrees:(CGFloat)angleInDegrees
{
   CGFloat angleOnTrackRadians = radiansFromDegrees(angleInDegrees);
   playerNode.position = [PlayerNode positionWithCenter:self.trackCenter radius:self.preparingTrackRadius angle:angleOnTrackRadians];
   playerNode.name = s_preparingPlayerName;
   playerNode.zRotation = angleOnTrackRadians + M_PI/2;
}

- (void)queuePlayerNodeForPlaying:(PlayerNode *)playerNode withDelay:(CGFloat)seconds
{
   // After 3 seconds, position back on the track
   dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      
      [self playPlayerNode:playerNode];
   });
}

- (void)playPlayerNode:(PlayerNode *)playerNode
{
   CGFloat angleOnTrackRadians = normalize([playerNode angleWithCenter:self.trackCenter]);
   CGPoint trackPosition = [PlayerNode positionWithCenter:self.trackCenter radius:self.trackRadius angle:angleOnTrackRadians];
   
   SKAction* jumpUpAction = [SKAction moveByX:0 y:50 duration:0.2];
   SKAction* jumpDownAction = [SKAction moveTo:trackPosition duration:0.2];
   jumpUpAction.timingMode = SKActionTimingEaseOut;
   jumpDownAction.timingMode = SKActionTimingEaseIn;
   [playerNode runAction:[SKAction sequence:@[jumpUpAction, jumpDownAction]] completion:^{
      
      playerNode.name = s_inGamePlayerName;
   }];
}

- (void)startGame
{
   self.isPlaying = YES;
   self.totalGameTime = 0;
   
   self.barNode.isAccelerating = YES;
   
   [[self childNodeWithName:@"instructions"] removeFromParent];
   
   [self enumerateChildNodesWithName:s_preparingPlayerName usingBlock:^(SKNode *node, BOOL *stop) {
      PlayerNode* playerNode = (PlayerNode *)node;
      [self playPlayerNode:playerNode];
      [playerNode updateAnimations];
   }];
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
      if ( self.isPlaying )
      {
         [self.controlledPlayerNode jump];
      }
      else
      {
         [self startGame];
      }
   }];

   self.leftSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
   self.rightSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
   self.upSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionUp;

   self.leftSwipeRecognizer.delegate = self;
   self.rightSwipeRecognizer.delegate = self;
   self.upSwipeRecognizer.delegate = self;

   [view addGestureRecognizer:self.leftSwipeRecognizer];
   [view addGestureRecognizer:self.rightSwipeRecognizer];
   [view addGestureRecognizer:self.upSwipeRecognizer];
}

- (void)removeGestureRecognizers
{
   [self.view removeGestureRecognizer:self.leftSwipeRecognizer];
   [self.view removeGestureRecognizer:self.rightSwipeRecognizer];
   [self.view removeGestureRecognizer:self.upSwipeRecognizer];
}

- (void)didMoveToView:(SKView *)view
{
   [self addGestureRecognizersToView:view];
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

- (AIPlayerNode *)aiPlayerNodeWithDifficulty:(CGFloat)difficulty
                       atTrackAngleInDegrees:(CGFloat)angleOnTrackDegrees
{
   AIPlayerNode* playerNode = [AIPlayerNode node];
   playerNode.difficulty = difficulty;
   [self preparePlayerNode:playerNode atAngleInDegrees:angleOnTrackDegrees];
   return playerNode;
}

- (void)setupNinja
{
   self.controlledPlayerNode = [PlayerNode node];
   [self preparePlayerNode:self.controlledPlayerNode atAngleInDegrees:270];
   [self addChild:self.controlledPlayerNode];
}

#pragma mark - Property Overrides
- (CGPoint)trackCenter
{
   CGFloat padding = 40;
   return CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) - self.trackRadius - padding);
}

- (CGFloat)trackRadius
{
   return CGRectGetWidth(self.frame)*.5 - 25;
}

- (CGFloat)preparingTrackRadius
{
   return self.trackRadius + 20;
}

- (NSInteger)numEnemiesLeft
{
   __block int enemiesLeft = 0;
   [self enumerateChildNodesWithName:s_inGamePlayerName usingBlock:^(SKNode *node, BOOL *stop) {
      if ( node != self.controlledPlayerNode )
         enemiesLeft++;
   }];
   return enemiesLeft;
}

- (NSInteger)numPreparingEnemies
{
   __block int ret = 0;
   [self enumerateChildNodesWithName:s_preparingPlayerName usingBlock:^(SKNode *node, BOOL *stop) {
      if ( node != self.controlledPlayerNode )
         ret++;
   }];
   return ret;
}

#pragma mark -

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
      
      self.totalGameTime = self.totalGameTime + dt;
      [self checkForEndGame];
   }
   
   self.lastTime = currentTime;
}

- (void)updatePlayers
{
   [self enumerateChildNodesWithName:s_inGamePlayerName usingBlock:^(SKNode *node, BOOL *stop) {
      PlayerNode* playerNode = (PlayerNode *)node;
      [playerNode updateAnimations];
   }];
   
   [self enumerateChildNodesWithName:s_preparingPlayerName usingBlock:^(SKNode *node, BOOL *stop) {
      PlayerNode* playerNode = (PlayerNode *)node;
      [playerNode updateAnimations];
   }];
}

- (void)updateDecisionsWithOldBarAngle:(CGFloat)oldBarAngle newBarAngle:(CGFloat)newBarAngle
{
   [self enumerateChildNodesWithName:s_inGamePlayerName usingBlock:^(SKNode *node, BOOL *stop) {
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
   
   [self enumerateChildNodesWithName:s_inGamePlayerName usingBlock:^(SKNode *node, BOOL *stop) {
      
      PlayerNode* playerNode = (PlayerNode *)node;
      CGFloat testAngle = normalize([playerNode angleWithCenter:self.trackCenter]);
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
}

-(void)checkForEndGame
{
   if ( !self.isPlaying )
      return;
   
   if ( self.controlledPlayerNode.state == PlayerStateDead )
   {
      [self endGame:NO];
   }
   
   
   if ( self.numEnemiesLeft == 0 && self.numPreparingEnemies == 0)
   {
      [self advanceToNextLevel];
   }
}

-(void)advanceToNextLevel
{
   self.currentLevelNumber = self.currentLevelNumber + 1;
   [self setupLevel:self.currentLevelNumber];
}

-(void)endGame:(BOOL)win
{
   self.scene.view.paused = YES;
   [self removeGestureRecognizers];
   
   SKSpriteNode* endColorNode = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithWhite:0.9 alpha:0.8] size:self.frame.size];
   endColorNode.anchorPoint = CGPointMake(0, 0);
   endColorNode.zPosition = 1;
   [self addChild:endColorNode];
   
   SKLabelNode* scoreNode = [SKLabelNode labelNodeWithFontNamed:@"Futura-Medium"];
   scoreNode.fontSize = 28;
   scoreNode.fontColor = [SKColor blackColor];
   scoreNode.text = [NSString stringWithFormat:@"Score: %ld seconds", (long)round(self.totalGameTime)];
   scoreNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 200);
   [self addChild:scoreNode];
   scoreNode.zPosition = 2;
   
   
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
