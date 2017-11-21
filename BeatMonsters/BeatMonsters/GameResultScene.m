//
//  GameResultScene.m
//  BeatMonsters
//
//  Created by cf on 2017/11/21.
//  Copyright © 2017年 chenfeng. All rights reserved.
//

#import "GameResultScene.h"
#import "GameScene.h"

@implementation GameResultScene

- (id)initWithSize:(CGSize)size result:(BOOL)result
{
    self = [super initWithSize:size];
    if (self) {
        [self initializeUserInterfaceWithResult:result];
    }
    return  self;
    
}

- (void)initializeUserInterfaceWithResult:(BOOL)result
{
    self.backgroundColor = [SKColor whiteColor];
    //初始化结果显示标签
    SKLabelNode *resultLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    resultLabel.text = result ? @"YOU Win":@"YOU Failed";
    resultLabel.fontSize = 30;
    resultLabel.fontColor = [SKColor blackColor];
    resultLabel.position = CGPointMake(self.size.width / 2, self.size.height /2);
    [self addChild:resultLabel];
    SKLabelNode *retryLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    retryLabel.text = @"try again";
    retryLabel.fontSize = 30;
    retryLabel.fontColor = [SKColor redColor];
    retryLabel.name = @"RetryLabel";
    retryLabel.position = CGPointMake(self.size.width / 2, self.size.height /2 - 50);
    [self addChild:retryLabel];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{//判断重新开始的点击
    CGPoint location = [[touches anyObject] locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    if ([node.name isEqualToString:@"RetryLabel"]) {
        //开始新游戏
        [self translateToGameScene];
    }
    
}

- (void)translateToGameScene
{
    //初始化游戏场景并展现
    GameScene *gameScene = [[GameScene alloc] initWithSize:self.size];
    
    SKTransition *transtion = [SKTransition revealWithDirection:SKTransitionDirectionDown duration:0.5];
    [self.view presentScene:gameScene transition:transtion];
    
    
}


@end
