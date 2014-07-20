//
//  SKScene+nodesWithName.m
//  PolyJump
//
//  Created by David Cheng on 7/19/14.
//  Copyright (c) 2014 Free the Robots. All rights reserved.
//

#import "SKScene+nodesWithName.h"

@implementation SKScene (nodesWithName)

- (NSArray *)nodesWithName:(NSString *)name
{
   NSMutableArray* ret = [NSMutableArray array];
   [self enumerateChildNodesWithName:name usingBlock:^(SKNode *node, BOOL *stop) {
      [ret addObject:node];
   }];
   return ret;
   
}

@end
