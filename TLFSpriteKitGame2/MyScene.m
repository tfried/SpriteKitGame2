//
//  MyScene.m
//  TLFSpriteKitGame2
//
//  Created by TLF on 7/26/14.
//  Copyright (c) 2014 Tea. All rights reserved.
//
#import "MyScene.h"
#import "GameOverScene.h"


static const uint32_t shipCategory =  0x1 << 0;
static const uint32_t obstacleCategory =  0x1 << 1;

static const float BG_VELOCITY = 100.0; //Velocity that background is going to move
static const float OBJECT_VELOCITY = 160.0;  //Velocity for missle

static inline CGPoint CGPointAdd(const CGPoint a, const CGPoint b)

{
    return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint CGPointMultiplyScalar(const CGPoint a, const CGFloat b)
{
    return CGPointMake(a.x * b, a.y * b);
}

NSTimeInterval _lastMissileAdded;

@implementation MyScene{
    SKSpriteNode *ship;
    SKAction *actionMoveUp;
    SKAction *actionMoveDown;
    SKAction *actionMoveLeft;
    SKAction *actionMoveRight;
    NSTimeInterval _lastUpdateTime;
    NSTimeInterval _dt;
    NSTimeInterval _lastMissileAdded;
}

-(id)initWithSize:(CGSize)size {
    
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor whiteColor];
        [self initalizingScrollingBackground];
        [self addShip];
        
        //Making self delegate of physics World
        self.physicsWorld.gravity = CGVectorMake(0,0);  //set gravity to 0
        self.physicsWorld.contactDelegate = self;       //send delegate when collision occurs
        
    }
    return self;
}

-(void)addShip
{
    //initalizing spaceship node
    ship = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
    [ship setScale:0.1];  //reduces size of spaceship to 1/10 original
    ship.zRotation = - M_PI / .1;  // direction ship points in
    
    //Adding SpriteKit physicsBody for collision detection
    ship.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:ship.size]; //creating a rectangle physics body for the ship which has same size as ship node
    ship.physicsBody.categoryBitMask = shipCategory;  //Sets the category bit mask to be the shipCategory defined earlier.
    ship.physicsBody.dynamic = YES;  //Setting dynamic YES means that physics engine will not control the movement of the ship
    ship.physicsBody.contactTestBitMask = obstacleCategory;
    ship.physicsBody.collisionBitMask = 0;  //On collision with missile we don’t want the ship to bounce off, so we set collisionBitMask as 0
    ship.name = @"ship";
   
    // ship.position = CGPointMake(120,160); //Setting position of ship on screen.
    ship.position = CGPointMake(280,40);
    
    [self addChild:ship];
    
    actionMoveUp = [SKAction moveByX:0 y:30 duration:.2];  //Defining SKAction for moving ship up
    actionMoveDown = [SKAction moveByX:0 y:-30 duration:.2];
    actionMoveLeft = [SKAction moveByX:30 y:0 duration:.2];
    actionMoveRight = [SKAction moveByX:-30 y:0 duration:.2];
}

//To make endlessly scrolling background, make two background images instead of one and lay them side-by-side. Then, as you scroll both images from right to left, once one of the images goes off-screen, you simply put it back to the right.
-(void)initalizingScrollingBackground
{
    for (int i = 0; i < 2; i++) {
        SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"bg"];
        
        bg.position = CGPointMake(i * bg.size.width, 0);
        bg.anchorPoint = CGPointZero;
        bg.name = @"bg";
        [self addChild:bg];
    }
    
}

- (void)moveBg
{
    [self enumerateChildNodesWithName:@"bg" usingBlock: ^(SKNode *node, BOOL *stop)
     {
         SKSpriteNode * bg = (SKSpriteNode *) node;
         CGPoint bgVelocity = CGPointMake(-BG_VELOCITY, 0);
       //  CGPoint amtToMove = CGPointMultiplyScalar(bgVelocity,_dt);
       //  bg.position = CGPointAdd(bg.position, amtToMove);

         
         //Checks if bg node is completely scrolled of the screen, if yes then put it at the end of the other node
         if (bg.position.x <= -bg.size.width)
         {
             bg.position = CGPointMake(bg.position.x + bg.size.width*2,
                                       bg.position.y);
         }
     }];
}

//use update method to keep track of lastMissileAdded time interval
-(void)update:(CFTimeInterval)currentTime {
    
    if (_lastUpdateTime)
    {
        _dt = currentTime - _lastUpdateTime;
    }
    else
    {
        _dt = 0;
    }
    _lastUpdateTime = currentTime;
    
    
    //interval in which missles are launched.. the lower the number, the more missles on the screen at a given time
    if( currentTime - _lastMissileAdded > .3)
    {
        _lastMissileAdded = currentTime + .3;
        [self addMissile];
    }
    
    [self moveBg];
    [self moveObstacle];
    
}

-(void)addMissile
{
    //initalizing spaceship node
    SKSpriteNode *missile;
    missile = [SKSpriteNode spriteNodeWithImageNamed:@"red-missile.png"];
    [missile setScale:0.05];
    
    //Adding SpriteKit physicsBody for collision detection
    missile.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:missile.size];
    missile.physicsBody.categoryBitMask = obstacleCategory;
    missile.physicsBody.dynamic = YES;
    missile.physicsBody.contactTestBitMask = shipCategory;
    missile.physicsBody.collisionBitMask = 0;
    missile.physicsBody.usesPreciseCollisionDetection = YES;
    missile.name = @"missile";
    //selecting random y position for missile
    int r = arc4random() % 300;
    missile.position = CGPointMake(self.frame.size.width + 20,r);
    [self addChild:missile];
}

- (void)moveObstacle
{
    NSArray *nodes = self.children; //collect all child nodes of the scene
    
    for(SKNode * node in nodes){
        if (![node.name  isEqual: @"bg"] && ![node.name  isEqual: @"ship"]) {
            SKSpriteNode *ob = (SKSpriteNode *) node;
            CGPoint obVelocity = CGPointMake(-OBJECT_VELOCITY, 0); //Set the velocity by which the node is going to move
            CGPoint amtToMove = CGPointMultiplyScalar(obVelocity,_dt); //Set the amount by which node has to move
            
            ob.position = CGPointAdd(ob.position, amtToMove); //Set new position of the node
            if(ob.position.x < -100)
            {
                [ob removeFromParent]; //remove any node which has scrolled off the screen
            }
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self.scene]; //track the location of the touch on the screen
    
    if(touchLocation.y >ship.position.y && touchLocation.x>ship.position.x){ //If the location is higher than and to the right of the ship’s location then we want to move the ship up.
        if(ship.position.y < 270){ //Setting offset from the edge so ship completely stays in bounds of the scene
            [ship runAction:actionMoveUp]; //Calling actionMoveUp to move the ship up by 30 points
            [ship runAction:actionMoveLeft];
        }
    }else if(touchLocation.y >ship.position.y && touchLocation.x<ship.position.x){
        if(ship.position.y<270){
            [ship runAction:actionMoveUp];
            [ship runAction:actionMoveRight];
        }
    }else if(touchLocation.y<ship.position.y && touchLocation.x>ship.position.x){
        if(ship.position.y >50){
            [ship runAction:actionMoveDown];
            [ship runAction:actionMoveLeft];
        }
    }
    else{
        if(ship.position.y > 50){
            [ship runAction:actionMoveDown];
            [ship runAction:actionMoveRight];
        }
    }
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    SKPhysicsBody *firstBody, *secondBody;
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    if ((firstBody.categoryBitMask & shipCategory) != 0 &&
        (secondBody.categoryBitMask & obstacleCategory) != 0)
    {
        [ship removeFromParent];
        SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
        SKScene * gameOverScene = [[GameOverScene alloc] initWithSize:self.size];
        [self.view presentScene:gameOverScene transition: reveal];
        
    }
}

@end