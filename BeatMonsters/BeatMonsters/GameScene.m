//
//  GameScene.m
//  BeatMonsters
//
//  Created by cf on 2017/11/21.
//  Copyright © 2017年 chenfeng. All rights reserved.
//

#import "GameScene.h"
#import <AVFoundation/AVFoundation.h>
#import "GameResultScene.h"

@interface GameScene ()
{
    SKSpriteNode *_player;
    
    NSMutableArray *_monsters;
    NSMutableArray *_projectiles;
    AVAudioPlayer *_backgroundMusicPlayer;
    //可以完成音频播放，可以重复
    SKAction *_projectileSoundEffectAction;
    
    NSInteger _monsterKillNumber;
    
}

- (void)initializeUserInterfaceWithSize:(CGSize)size;
//添加怪物
- (void)addMonster;
//添加飞镖
- (void)addProjectileAtPoint:(CGPoint)point;
//碰撞检测
- (void)updateColission;
//初始化音频
- (void)initializeMedia;
//场景切换
- (void)translateToGameResultscenewithResult:(BOOL)result;

@end

@implementation GameScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        _monsterKillNumber = 0;
        [self initializeUserInterfaceWithSize:size];
        [self initializeMedia];
    }
    return self;
}

-(void)initializeUserInterfaceWithSize:(CGSize)size
{
    
    self.backgroundColor = [SKColor whiteColor];
    //使用图片初始化精灵，精灵大小为图片大小
    _player = [SKSpriteNode spriteNodeWithImageNamed:@"player.png"];
    //配置精灵位置
    _player.position = CGPointMake(_player.size.width / 2,size.height /2 );
    //添加精灵到scene中
    [self addChild:_player];
    
    //添加怪物
    SKAction *addMonsterAction = [SKAction runBlock:^{
        [self addMonster];
    }];
    SKAction *waitAction = [SKAction waitForDuration:1 withRange:0.5];
    //将添加的怪物和等待行为打包成一个行为
    SKAction *totalAction = [SKAction sequence:@[addMonsterAction,waitAction]];
    //创建无限怪物
    SKAction *foreverAction = [SKAction repeatActionForever:totalAction];
    //让场景执行行为
    [self runAction:foreverAction];
}



-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    UITouch *touch = [touches anyObject];
    //获取触摸点在场景中的坐标
    CGPoint location = [touch locationInNode:self];
    
    [self addProjectileAtPoint:location];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    /* Called when a touch begins */
    UITouch *touch = [touches anyObject];
    //获取触摸点在场景中的坐标
    CGPoint location = [touch locationInNode:self];
    
    //主怪兽的移动
    SKAction * moveAction =  [SKAction moveTo:location duration:2];
    
    SKAction *speedAction = [SKAction speedTo:5 duration:1];
    
    SKAction *groupAction = [SKAction group:@[
                                              moveAction,
                                              speedAction
                                              ]];
    
    [_player runAction:groupAction];
    
    [self addProjectileAtPoint:location];
    
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    [self updateColission];
}

#pragma mark - SpriteKit method
- (void)initializeMedia
{
    NSURL *url = [[NSBundle mainBundle] URLForAuxiliaryExecutable:@"background-music-aac.caf"];
    NSError *error = nil;
    _backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    NSAssert(!error, @"failed message'%@'",[error localizedDescription]);
    _backgroundMusicPlayer.numberOfLoops = -1;
    [_backgroundMusicPlayer prepareToPlay];
    [_backgroundMusicPlayer play];
    
    //初始化武器音效
    _projectileSoundEffectAction = [SKAction playSoundFileNamed:@"pew-pew-lei.caf" waitForCompletion:NO];
    
}

- (void)updateColission
{
    SKSpriteNode *deleteMonster = nil;
    SKSpriteNode *deleteProjectile = nil;
    for (SKSpriteNode *monster in _monsters ) {
        for (SKSpriteNode *projectile in _projectiles) {
            //判定碰撞，矩形相交
            if (CGRectIntersectsRect(monster.frame, projectile.frame)) {
                deleteMonster = monster;
                deleteProjectile = projectile;
            }
        }
        
    }
    if (deleteMonster && deleteProjectile) {
        [deleteMonster removeFromParent];
        [deleteProjectile removeFromParent];
        [_monsters removeObject:deleteMonster];
        [_projectiles removeObject:deleteProjectile];
        if (++_monsterKillNumber >= 20) {
            [self translateToGameResultscenewithResult:YES];
        }
    }
    
}

- (void)addMonster
{
    if (!_monsters) {
        _monsters = [NSMutableArray array];
    }
    CGSize  size = self.size;
    //初始化敌人精灵
    SKSpriteNode *monster = [SKSpriteNode spriteNodeWithImageNamed:@"monster.png"];
    //最小Y坐标
    NSInteger minimumy = monster.size.height / 2;
    //最大Y坐标
    NSInteger maximumy = size.height - monster.size.height / 2;
    //Y的随机范围
    NSInteger rangY = maximumy - minimumy;
    //Y的真实坐标
    NSInteger actualy = minimumy +arc4random() % rangY;
    monster.position = CGPointMake(size.width + monster.size.width / 2,actualy);
    [self addChild:monster];
    [_monsters addObject:monster];
    
    //时间计算移动时长
    NSInteger minimumDuration = 2.0;
    NSInteger maximumDuration = 4.0;
    //时长随机范围
    NSInteger rangeDuration = maximumDuration - minimumDuration;
    
    //实际时长
    NSInteger actualDuration = minimumDuration +arc4random() % rangeDuration;
    //  出事化并执行移动事件
    SKAction *moveAction = [SKAction moveTo:CGPointMake(-monster.size.width / 2, monster.position.y) duration:actualDuration];
    //执行行为
    [monster runAction:moveAction completion:^{
        //移除怪物吗，清理内存
        [monster removeFromParent];
        [_monsters removeObject:monster];
        //游戏失败
        [self translateToGameResultscenewithResult:NO];
    }];
}

- (void)addProjectileAtPoint:(CGPoint)point
{
    //    //判断点击是否有效
    //    if (point.x < _player.position.x) {
    //        return;
    //    }
    if (!_projectiles) {
        _projectiles = [NSMutableArray array];
    }
    //初始化飞镖
    SKSpriteNode *projectile = [SKSpriteNode spriteNodeWithImageNamed:@"projectile.png"];
    projectile.position = CGPointMake(_player.position.x + projectile.size.width / 2, _player.position.y);
    [self  addChild:projectile];
    [_projectiles addObject:projectile];
    
    CGSize size = self.size;

    CGFloat actualx =  size.width + projectile.size.width / 2;
    //最终点位置
    CGPoint actualPoint = CGPointMake(actualx, point.y);
    //求移动事件
    CGFloat actualOffsetX = actualPoint.x - projectile.position.x;
    CGFloat actualOffsetY = actualPoint.y - projectile.position.y;
    //移动距离
    CGFloat distance = sqrtf(pow(actualOffsetX, 2) + pow(actualOffsetY, 2));
    //移动速度
    CGFloat velcaity = size.width / 1;
    //移动时长
    NSTimeInterval duration = distance/velcaity;
    //移动行为
    SKAction *moveAction = [SKAction moveTo:actualPoint duration:duration];
    
    //旋转行为
    SKAction *rotationASction = [SKAction rotateByAngle:M_PI duration:0.2];
    SKAction *rotateRepeatAction = [SKAction repeatAction:rotationASction count:10];
    //执行行为
    [projectile runAction:[SKAction group:@[moveAction,rotateRepeatAction,_projectileSoundEffectAction]] completion:^{
        [projectile removeFromParent];
        [_projectiles removeObject:projectile];
    }];
    
}

- (void)translateToGameResultscenewithResult:(BOOL)result
{
    [self removeAllActions];
    [_backgroundMusicPlayer stop];
    GameResultScene *resutlScene = [[GameResultScene alloc] initWithSize:self.size result:result];
    SKTransition *transtion = [SKTransition revealWithDirection:SKTransitionDirectionUp duration:0.5];
    [self.view presentScene:resutlScene  transition:transtion];
}


@end
