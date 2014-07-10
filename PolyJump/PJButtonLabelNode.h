//
//  PJPlayLabelNode.h
//  PolyJump
//
//  Created by Gregory Klein on 7/9/14.
//  Copyright (c) 2014 Free the Robots. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface PJButtonLabelNode : SKLabelNode

+ (instancetype)nodeWithText:(NSString *)text;

@property (nonatomic) SKScene* destinationScene;
@property (nonatomic, copy) dispatch_block_t touchEndedHandler;

@end
