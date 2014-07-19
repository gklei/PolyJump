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
   PlayerNode* playerNode = [PlayerNode node];
   CGFloat angleOnTrackDegrees = rand() % 360;
   CGFloat angleOnTrackRadians = radiansFromDegrees(angleOnTrackDegrees);
   playerNode.position = [PlayerNode positionWithCenter:self.trackCenter radius:self.trackRadius angle:angleOnTrackRadians];
   playerNode.name = @"enemy";
   
//   CGFloat playerRotation = angleOnTrack;
   playerNode.zRotation = angleOnTrackRadians + M_PI/2;
   [self addChild:playerNode];
}

- (void)setupNinja
{
   self.controlledPlayerNode = [PlayerNode node];
   self.controlledPlayerNode.position = self.ninjaCenter;
   [self addChild:self.controlledPlayerNode];
}

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

- (void)update:(NSTimeInterval)currentTime
{
   if ( self.lastTime )
   {
      NSTimeInterval dt = currentTime - self.lastTime;
      CGFloat oldBarAngle = self.barNode.zRotation;
      [self.barNode updateWithDeltaTime:dt];
      [self hitTestWithOldBarAngle:oldBarAngle newBarAngle:self.barNode.zRotation];
   }

   [self enumerateChildNodesWithName:@"enemy" usingBlock:^(SKNode *node, BOOL *stop) {
      PlayerNode* playerNode = (PlayerNode *)node;
      [playerNode update];
   }];
   
   [self.controlledPlayerNode update];

   self.lastTime = currentTime;
}

-(void)hitTestWithOldBarAngle:(CGFloat)oldBarAngle newBarAngle:(CGFloat)newBarAngle
{
   CGFloat angleDelta = newBarAngle - oldBarAngle;
   CGFloat angleStart = normalize(oldBarAngle);
   CGFloat angleEnd   = angleStart + angleDelta;
   
   [self enumerateChildNodesWithName:@"enemy" usingBlock:^(SKNode *node, BOOL *stop) {
      PlayerNode* playerNode = (PlayerNode *)node;
      CGFloat testAngle = normalize([playerNode angleWithCenter:self.trackCenter radius:self.trackRadius]);
      if ( angleInRange(testAngle, angleStart, angleEnd) )
      {
//         NSLog(@"hit playerNode %@", playerNode);
         self.numHitPegs = self.numHitPegs + 1;
      }
   }];
   
//   if ( self.numHitPegs > 3 )
//      [self endGame];
}

-(void)endGame
{
   self.scene.view.paused = YES;
   [self removeGestureRecognizers];
   
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
//   NSLog(@"touchesBegan");
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
}



@end
