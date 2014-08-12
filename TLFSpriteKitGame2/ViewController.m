//
//  ViewController.m
//  TLFSpriteKitGame2
//
//  Created by TLF on 7/26/14.
//  Copyright (c) 2014 Tea. All rights reserved.
//

#import "ViewController.h"
#import "MyScene.h"

@implementation ViewController

//creating the scene from viewWillLayoutSubviews method instead of viewDidLoad. When viewDidLoad is called it is not aware of the layout of changes, hence it will not set the bounds of the scene correctly
- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    SKView * skView = (SKView *)self.view;
    
    if (!skView.scene) {
        skView.showsFPS = YES;
        skView.showsNodeCount = YES;
        
        // Create and configure the scene.
        SKScene * scene = [MyScene sceneWithSize:skView.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        
        // Present the scene.
        [skView presentScene:scene];
    }
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}





@end
