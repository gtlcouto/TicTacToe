//
//  ViewController.m
//  TicTacToe
//
//  Created by Diego Cichello on 1/8/15.
//  Copyright (c) 2015 Mobile Makers. All rights reserved.
//

#import "GameViewController.h"
#import "WinConditionChecker.h"
#import "AppDelegate.h"

#pragma mark - Properties
@interface GameViewController () <UIGestureRecognizerDelegate, UIAlertViewDelegate>

#pragma mark Game Labels
@property (weak, nonatomic) IBOutlet UILabel *labelRow1Column1;
@property (weak, nonatomic) IBOutlet UILabel *labelRow1Column2;
@property (weak, nonatomic) IBOutlet UILabel *labelRow1Column3;
@property (weak, nonatomic) IBOutlet UILabel *labelRow2Column1;
@property (weak, nonatomic) IBOutlet UILabel *labelRow2Column2;
@property (weak, nonatomic) IBOutlet UILabel *labelRow2Column3;
@property (weak, nonatomic) IBOutlet UILabel *labelRow3Column1;
@property (weak, nonatomic) IBOutlet UILabel *labelRow3Column2;
@property (weak, nonatomic) IBOutlet UILabel *labelRow3Column3;

@property NSArray *gameLabelsArray;

#pragma mark Other Labels
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UILabel *playerTurnLabel;

@property (strong, nonatomic) IBOutlet UIView *buttonView;

#pragma mark View Constraints
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *labelPortraitConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *labelLandscapeConstraints;

#pragma mark Misc. Properties
@property NSTimer *timeToPlay;
@property NSUInteger remainingTicks;
@property WinConditionChecker *winConditionChecker;

@property NSMutableSet *playerXMoves;
@property NSMutableSet *playerOMoves;

@property BOOL isPlayerXTurn;
@property BOOL amICurrentPlayer;
@property BOOL didPlayerWin;
@property BOOL didGameDraw;

@property (strong, nonatomic) AppDelegate *appDelegate;

@end

#pragma mark - Implementation
@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];



    self.isPlayerXTurn = YES;
    //Initialize player move sets to empty set
    self.playerXMoves = [[NSMutableSet alloc]init];
    self.playerOMoves = [[NSMutableSet alloc]init];

    //Initialize the winConditionChecker with all the win conditions
    self.winConditionChecker = [[WinConditionChecker alloc]initWithWinningConditionsSet];

    //Put the labels into NSArray for easy iteration
    self.gameLabelsArray= [NSArray arrayWithObjects:self.labelRow1Column1,self.labelRow1Column2,self.labelRow1Column3,self.labelRow2Column1,self.labelRow2Column2,self.labelRow2Column3,self.labelRow3Column1, self.labelRow3Column2, self.labelRow3Column3,nil];
    [self createNewGame];

    //Initialize timer
    self.timeToPlay = [NSTimer scheduledTimerWithTimeInterval: 1.0 target: self selector: @selector(handleTimerTick) userInfo: nil repeats: YES];

    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    self.amICurrentPlayer = self.appDelegate.mcManager.isPlayFirst;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveDataWithNotificationOnGame:)
                                                 name:@"MCDidReceiveDataNotification"
                                               object:nil];
}

- (IBAction)tapHandler:(UITapGestureRecognizer *)gesture
{
    UILabel *labelTouched = [self findLabelUsingPoint: [gesture locationInView:self.buttonView]];
    NSString *labelTag = [NSString stringWithFormat:@"%li",(long)labelTouched.tag];

    //If labelTouched has not been played and also exists
    if ((!([self.playerXMoves containsObject:labelTag]  ||
        [self.playerOMoves containsObject:labelTag])) && labelTouched!=nil )
    {
        //Multiplayer
        if (self.isMultiplayer)
        {
            [self multiplayerLogic:labelTouched];

        }
        //Singleplayer
        else if (self.isSinglePlayerEasy || self.isSinglePlayerHard)
        {
            [self singleplayerLogic:labelTouched];
        }
        else if (self.isMPCMultiplayer)
        {
            if (self.amICurrentPlayer)
            {

                if ((!([self.playerXMoves containsObject:labelTag]  ||
                       [self.playerOMoves containsObject:labelTag])) && labelTouched!=nil ){
                    [self sendMessage:labelTag];
                    if (self.isPlayerXTurn)
                    {
                        [self changeLabelToX:labelTouched];
                        self.playerTurnLabel.text = @"O's turn";
                        [self.playerXMoves addObject:labelTag];
                        self.didPlayerWin = [self.winConditionChecker checkWinConditions:self.playerXMoves];
                    } else
                    {
                        [self changeLabelToO:labelTouched];
                        [self.playerOMoves addObject:labelTag];
                        self.playerTurnLabel.text = @"X's turn";
                        self.didPlayerWin = [self.winConditionChecker checkWinConditions:self.playerOMoves];
                    }
                    //add to set
                    //check set to subsets
                    [self gameEndedCheck];
                    
                    self.isPlayerXTurn = !self.isPlayerXTurn;
                    self.amICurrentPlayer = !self.amICurrentPlayer;
                }
            }
        }

        self.remainingTicks = 31;
        self.timeToPlay = [NSTimer scheduledTimerWithTimeInterval: 1.0 target: self selector: @selector(handleTimerTick) userInfo: nil repeats: NO];

    }
    //Multiplayer multiple devices logic
    }

- (void) createNewGame
{
    for (UILabel *label in self.gameLabelsArray)
    {
        label.text = @"";
    }

    self.isPlayerXTurn = YES;
    self.playerTurnLabel.text = @"X's turn";
    self.playerXMoves = [[NSMutableSet alloc]init];
    self.playerOMoves = [[NSMutableSet alloc]init];
    self.didPlayerWin = NO;
    self.didGameDraw = NO;
    self.remainingTicks = 31;

}

- (void) CPUMoves
{
    NSMutableArray *availableSpaces = [[NSMutableArray alloc]init];
    for (UILabel *label in self.gameLabelsArray)
    {
        if ([label.text isEqualToString:@""] || !(label.text))
        {
            [availableSpaces addObject:[NSString stringWithFormat:@"%li", (long)label.tag]];
        }
    }
    if(availableSpaces.count > 0)
    {
        if (self.isSinglePlayerEasy)
        {
            [self CPUMoveEasy:availableSpaces];
        }
        //Hard Single Player - CPU implements optimal TicTacToe strategy
        else if(self.isSinglePlayerHard)
        {
            [self CPUMoveHard];

        }
    }
    
}

#pragma mark CPU AI Methods
- (void)CPUMoveEasy:(NSMutableArray *)availableSpaces
{
    NSUInteger randomIndex = arc4random() % [availableSpaces count];

    UILabel *selectedSpace = (UILabel *)[self.view viewWithTag:[[availableSpaces objectAtIndex:randomIndex] integerValue]];
    [self changeLabelToO:selectedSpace];
    [self.playerOMoves addObject:[availableSpaces objectAtIndex:randomIndex]];
    self.didPlayerWin = [self.winConditionChecker checkWinConditions:self.playerOMoves];
}

- (void)CPUMoveHard
{
    NSArray *corners = [NSArray arrayWithObjects:self.labelRow1Column1,self.labelRow1Column3,self.labelRow3Column1,self.labelRow3Column3, nil];

    //First move
    if (self.playerXMoves.count ==1)
    {
        //if player X plays center space on first move
        if ([self.playerXMoves containsObject:@"5"])
        {
            //CPU places move on random space
            NSUInteger randomIndex = arc4random() % [corners count];
            [self changeLabelToO:corners[randomIndex]];
            UILabel *label = corners[randomIndex];
            NSString *labelTag = [NSString stringWithFormat:@"%li",(long)label.tag];
            [self.playerOMoves addObject:labelTag];

        }
        else
        {
            //CPU plays in center
            [self changeLabelToO:self.labelRow2Column2];
            [self.playerOMoves addObject:[NSString stringWithFormat:@"%li", (long)self.labelRow2Column2.tag]];
            self.didPlayerWin = [self.winConditionChecker checkWinConditions:self.playerOMoves];

        }
    }
    //Subsequent moves
    else
    {
        NSString *labelNumber = [self.winConditionChecker tryToWinTheGame:self.playerXMoves :self.playerOMoves];
        //If there's a move that lets CPU win game, have CPU play move
        if (labelNumber != nil)
        {
            [self changeLabelToO:self.gameLabelsArray[[labelNumber intValue]-1]];
            [self.playerOMoves addObject:labelNumber];
            self.didPlayerWin = [self.winConditionChecker checkWinConditions:self.playerOMoves];

        }
        else
        {
            labelNumber = [self.winConditionChecker blockPlayerFromWinningTheGame:self.playerXMoves set2:self.playerOMoves];
            //if there's a move that blocks player from winning, have CPU play move
            if(labelNumber != nil)
            {
                [self changeLabelToO:self.gameLabelsArray[[labelNumber intValue]-1] ];
                [self.playerOMoves addObject:labelNumber];
                self.didPlayerWin = [self.winConditionChecker checkWinConditions:self.playerOMoves];
            }
            else
            {
                //if there's a move that block player fork, have CPU play move
                labelNumber = [self.winConditionChecker blockFork:self.playerXMoves set2:self.playerOMoves];

                [self changeLabelToO:self.gameLabelsArray[[labelNumber intValue]-1]];
                [self.playerOMoves addObject:labelNumber];
                self.didPlayerWin = [self.winConditionChecker checkWinConditions:self.playerOMoves];

            }


        }

    }
}

#pragma marks Alert Methods
-(void)drawAlert
{
    UIAlertView *gameEndedAlertView = [[UIAlertView alloc]init];
    gameEndedAlertView.delegate = self;
    [gameEndedAlertView addButtonWithTitle: @"Play Again?"];
    gameEndedAlertView.title = [NSString stringWithFormat:@"Cat Game! That's a Shame!"];
    [gameEndedAlertView show];

}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0: [self createNewGame];
    }
}

#pragma mark TicTacToe Logic Helper Methods
- (void)multiplayerLogic:(UILabel *)labelTouched
{
    NSString *labelTag = [NSString stringWithFormat:@"%li", labelTouched.tag];
    if (self.isPlayerXTurn)
    {
        [self changeLabelToX:labelTouched];
        self.playerTurnLabel.text = @"O's turn";
        [self.playerXMoves addObject:labelTag];
        self.didPlayerWin = [self.winConditionChecker checkWinConditions:self.playerXMoves];
    }
    else
    {
        [self changeLabelToO:labelTouched];
        self.playerTurnLabel.text = @"X's turn";
        [self.playerOMoves addObject:labelTag];
        self.didPlayerWin = [self.winConditionChecker checkWinConditions:self.playerOMoves];
    }

    [self gameEndedCheck];

    self.isPlayerXTurn = !self.isPlayerXTurn;
}

- (void)singleplayerLogic:(UILabel *)labelTouched
{
    NSString *labelTag = [NSString stringWithFormat:@"%li", labelTouched.tag];
    [self changeLabelToX:labelTouched];
    self.playerTurnLabel.text = @"O's turn";
    [self.playerXMoves addObject:labelTag];
    self.didPlayerWin = [self.winConditionChecker checkWinConditions:self.playerXMoves];

    [self gameEndedCheck];

    self.isPlayerXTurn = !self.isPlayerXTurn;
    if(!self.didPlayerWin && !self.didGameDraw)
    {
        [self CPUMoves];
        [self gameEndedCheck];
    }
    self.isPlayerXTurn = YES;
    self.playerTurnLabel.text = @"X's turn";
}

#pragma mark Change Label Helper Methods
- (void) changeLabelToO:(UILabel *)label
{
    label.text = [NSString stringWithFormat:@"O"];
    label.textColor = [UIColor redColor];
}

- (void) changeLabelToX:(UILabel *)label
{
    label.text = [NSString stringWithFormat:@"X"];
    label.textColor = [UIColor blueColor];
}

#pragma mark Orientation Constraint Methods
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self updateViewConstraints];
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation))
    {
        [self.buttonView removeConstraints:self.labelLandscapeConstraints];
        [self.buttonView addConstraints:self.labelPortraitConstraints];
    } else
    {
        [self.buttonView removeConstraints:self.labelPortraitConstraints];
        [self.buttonView addConstraints:self.labelLandscapeConstraints];
    }
}

#pragma mark Peer-to-Peer Connectivity

-(void)sendMessage:(NSString *)rawDataString{
    NSData *dataToSend = [rawDataString dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *allPeers = _appDelegate.mcManager.session.connectedPeers;
    NSError *error;

    [_appDelegate.mcManager.session sendData:dataToSend
                                     toPeers:allPeers
                                    withMode:MCSessionSendDataReliable
                                       error:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
}

-(void)didReceiveDataWithNotificationOnGame:(NSNotification *)notification{
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    //    NSString *peerDisplayName = peerID.displayName;

    NSData *receivedData = [[notification userInfo] objectForKey:@"data"];
    NSString *receivedText = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];

    UILabel *label = (UILabel *)[self.view viewWithTag:[receivedText intValue]];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.isPlayerXTurn) {

            [self changeLabelToX:label];
            self.playerTurnLabel.text = @"O's turn";
            [self.playerXMoves addObject:[NSString stringWithFormat:@"%li",label.tag]];
            self.didPlayerWin = [self.winConditionChecker checkWinConditions:self.playerXMoves];
        } else
        {
            [self changeLabelToO:label];
            [self.playerOMoves addObject:[NSString stringWithFormat:@"%li",(long)label.tag]];
            self.playerTurnLabel.text = @"X's turn";
            self.didPlayerWin = [self.winConditionChecker checkWinConditions:self.playerOMoves];
        }
        //add to set
        //check set to subsets
        [self gameEndedCheck];
        self.amICurrentPlayer = !self.amICurrentPlayer;
        self.isPlayerXTurn = !self.isPlayerXTurn;
    });
}

#pragma mark Other Methods
// --------------------------------------- Other Methods ------------------------------------------
-(void)handleTimerTick
{
    if (!self.didPlayerWin)
    {
        self.remainingTicks--;
        self.timerLabel.text = [NSString stringWithFormat:@"Time Left: %@", [NSNumber numberWithUnsignedInt: (int)self.remainingTicks]];

        if (self.remainingTicks <= 0) {

            if (self.isPlayerXTurn)
            {

                self.playerTurnLabel.text = @"O's turn";
            }
            else
            {
                self.playerTurnLabel.text = @"X's turn";
            }
            self.isPlayerXTurn = !self.isPlayerXTurn;
            self.remainingTicks = 30;
        }
    }
}

- (UILabel *)findLabelUsingPoint: (CGPoint)point
{
    UILabel  *returnLabel = nil;
    for (UILabel *label in self.gameLabelsArray)
    {
        if (CGRectContainsPoint(label.frame, point))
        {
            return label;
        }
    }
    return returnLabel;

}

-(void)gameEndedCheck
{
    UIAlertView *gameEndedAlertView = [[UIAlertView alloc]init];
    gameEndedAlertView.delegate = self;
    [gameEndedAlertView addButtonWithTitle: @"Play Again?"];

    if (self.didPlayerWin && self.isPlayerXTurn)
    {
        gameEndedAlertView.title = [NSString stringWithFormat:@"Player X Wins!"];
        [gameEndedAlertView show];
    }
    else if (self.didPlayerWin)
    {
        gameEndedAlertView.title = [NSString stringWithFormat:@"Player O Wins!"];
        [gameEndedAlertView show];

    }
    //if neither player wins and all spaces have been filled
    if (!self.didPlayerWin && (self.playerOMoves.count + self.playerXMoves.count) == 9)
    {
        [self drawAlert];
        self.didGameDraw = YES;
    }
}

@end
