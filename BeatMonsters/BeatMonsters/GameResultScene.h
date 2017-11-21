//
//  GameResultScene.h
//  BeatMonsters
//
//  Created by cf on 2017/11/21.
//  Copyright © 2017年 chenfeng. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GameResultScene : SKScene

- (void)initializeUserInterfaceWithResult:(BOOL)result;
- (id)initWithSize:(CGSize)size result:(BOOL)result;

- (void)translateToGameScene;

@end
