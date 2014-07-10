//
//  PJPlayLabelNode.h
//  PolyJump
//
//  Created by Gregory Klein on 7/9/14.
//  Copyright (c) 2014 Free the Robots. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface PJPlayLabelNode : SKLabelNode

+ (instancetype)playLabelNode;

@property (nonatomic) SKScene* destinationScene;
@property (nonatomic, copy) dispatch_block_t touchEndedHandler;

@end
