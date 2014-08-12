//
//  GameOverScene.m
//  TLFSpriteKitGame2
//
//  Created by TLF on 7/26/14.
//  Copyright (c) 2014 Tea. All rights reserved.
//

#import "GameOverScene.h"
#import "MyScene.h"

@implementation GameOverScene
-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        // 1
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        
        // 2
        NSString * message;
        message = @"Game Over";
        // 3
        SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Marker Felt"];
        label.text = message;
        label.fontSize = 40;
        label.fontColor = [SKColor redColor];
        label.position = CGPointMake(self.size.width/2, self.size.height/2);
        [self addChild:label];
        
        //4
        NSString * retrymessage;
        retrymessage = @"Replay Game";
        SKLabelNode *retryButton = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        retryButton.text = retrymessage;
        retryButton.fontColor = [SKColor blueColor];
        retryButton.position = CGPointMake(self.size.width/2, 50);
        retryButton.name = @"retry";
        [self addChild:retryButton];
        
    }
    return self;
}

//To track when user hit the replay button
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location]; //when user touches anywhere on the screen
    
    if ([node.name isEqualToString:@"retry"]) {
        
        //transition back to MyScene to restart the game
        SKTransition *reveal = [SKTransition fadeWithDuration:1.0];
        
        //SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5]; //choose any transition here
        MyScene * scene = [MyScene sceneWithSize:self.view.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        [self.view presentScene:scene transition: reveal];
        
    }
}
@end
