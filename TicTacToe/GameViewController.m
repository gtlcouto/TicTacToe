//
//  ViewController.m
//  TicTacToe
//
//  Created by Diego Cichello on 1/8/15.
//  Copyright (c) 2015 Mobile Makers. All rights reserved.
//

#import "GameViewController.h"
#import "WinConditionChecker.h"

@interface GameViewController () <UIGestureRecognizerDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *labelRow1Column1;
@property (weak, nonatomic) IBOutlet UILabel *labelRow1Column2;
@property (weak, nonatomic) IBOutlet UILabel *labelRow1Column3;
@property (weak, nonatomic) IBOutlet UILabel *labelRow2Column1;
@property (weak, nonatomic) IBOutlet UILabel *labelRow2Column2;
@property (weak, nonatomic) IBOutlet UILabel *labelRow2Column3;
@property (weak, nonatomic) IBOutlet UILabel *labelRow3Column1;
@property (weak, nonatomic) IBOutlet UILabel *labelRow3Column2;
@property (weak, nonatomic) IBOutlet UILabel *labelRow3Column3;

@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UILabel *playerTurnLabel;
@property (strong, nonatomic) IBOutlet UILabel *winLabel;
@property (strong, nonatomic) IBOutlet UIView *buttonView;

@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *labelPortraitConstraints;

@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *labelLandscapeConstraints;

@property NSTimer *timeToPlay;
@property NSUInteger remainingTicks;
@property WinConditionChecker *winConditionChecker;

@property NSArray *gameLabelsArray;

@property NSMutableSet *playerXMoves;
@property NSMutableSet *playerOMoves;

@property BOOL isPlayerXTurn;
@property BOOL didPlayerWin;
@property BOOL didGameDraw;



@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.isPlayerXTurn = YES;
    //initialize player move sets to empty set
    self.playerXMoves = [[NSMutableSet alloc]init];
    self.playerOMoves = [[NSMutableSet alloc]init];

    //initialize the winConditionChecker with all the win conditions
    self.winConditionChecker = [[WinConditionChecker alloc]initWithWinningConditionsSet];

    //Put the labels into NSArray for easy iteration
    self.gameLabelsArray= [NSArray arrayWithObjects:self.labelRow1Column1,self.labelRow1Column2,self.labelRow1Column3,self.labelRow2Column1,self.labelRow2Column2,self.labelRow2Column3,self.labelRow3Column1, self.labelRow3Column2, self.labelRow3Column3,nil];
    [self createNewGame];

    self.timeToPlay = [NSTimer scheduledTimerWithTimeInterval: 1.0 target: self selector: @selector(handleTimerTick) userInfo: nil repeats: YES];
}

- (IBAction)tapHandler:(UITapGestureRecognizer *)gesture
{
    UILabel *labelTouched = [self findLabelUsingPoint: [gesture locationInView:self.buttonView]];
    NSString *labelTag = [NSString stringWithFormat:@"%li",(long)labelTouched.tag];

    //if labelTouched has not been played and also exists
    if ((!([self.playerXMoves containsObject:labelTag]  ||
        [self.playerOMoves containsObject:labelTag])) && labelTouched!=nil )
    {
        //Multiplayer
        if (self.isMultiplayer)
        {
            if (self.isPlayerXTurn)
            {
                labelTouched.text = @"X";
                labelTouched.textColor = [UIColor blueColor];
                self.playerTurnLabel.text = @"O's turn";

                [self.playerXMoves addObject:labelTag];
                self.didPlayerWin = [self.winConditionChecker checkWinConditions:self.playerXMoves];
            }
            else
            {
                labelTouched.text = @"O";
                labelTouched.textColor = [UIColor redColor];
                self.playerTurnLabel.text = @"X's turn";

                [self.playerOMoves addObject:labelTag];
                self.didPlayerWin = [self.winConditionChecker checkWinConditions:self.playerOMoves];
            }

            [self gameEndedCheck];

            self.isPlayerXTurn = !self.isPlayerXTurn;

        }
        //Singleplayer
        else
        {
            labelTouched.text = @"X";
            labelTouched.textColor = [UIColor blueColor];
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
        self.remainingTicks = 31;
        self.timeToPlay = [NSTimer scheduledTimerWithTimeInterval: 1.0 target: self selector: @selector(handleTimerTick) userInfo: nil repeats: NO];

    }


}


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

#pragma Other Methods
// --------------------------------------- Other Methods ------------------------------------------

- (UILabel *)findLabelUsingPoint: (CGPoint)point
{
    UILabel  *returnLabel = nil;
    for (UILabel *label in self.gameLabelsArray)
    {
        if (CGRectContainsPoint(label.frame, point) && label.tag != self.winLabel.tag)
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
        self.didGameDraw = true;
    }


}

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

- (void) createNewGame

{
    for (UILabel *label in self.gameLabelsArray)
    {
        label.text = @"";
    }
    self.isPlayerXTurn = true;
    self.playerTurnLabel.text = @"X's turn";
    self.playerXMoves = [[NSMutableSet alloc]init];
    self.playerOMoves = [[NSMutableSet alloc]init];
    self.didPlayerWin = false;
    self.didGameDraw = false;
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
        //Easy Single Player - CPU does random moves
        if (self.isSinglePlayerEasy)
        {
            NSUInteger randomIndex = arc4random() % [availableSpaces count];

            UILabel *selectedSpace = (UILabel *)[self.view viewWithTag:[[availableSpaces objectAtIndex:randomIndex] integerValue]];
            selectedSpace.text = [NSString stringWithFormat:@"O"];
            selectedSpace.textColor = [UIColor redColor];
            [self.playerOMoves addObject:[availableSpaces objectAtIndex:randomIndex]];
            self.didPlayerWin = [self.winConditionChecker checkWinConditions:self.playerOMoves];
        }
        //Hard Single Player - CPU implements optimal TicTacToe strategy
        else if(self.isSinglePlayerHard)
        {
            NSArray *corners = [NSArray arrayWithObjects:self.labelRow1Column1,self.labelRow1Column3,self.labelRow3Column1,self.labelRow3Column3, nil];

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

                    [self changeLabelToO:self.labelRow2Column2];
                    [self.playerOMoves addObject:[NSString stringWithFormat:@"%li", (long)self.labelRow2Column2.tag]];
                    self.didPlayerWin = [self.winConditionChecker checkWinConditions:self.playerOMoves];

                }
            }
            else
            {
                NSString *labelNumber = [self.winConditionChecker tryToWinTheGame:self.playerXMoves :self.playerOMoves];
                if (labelNumber != nil)
                {

                    [self changeLabelToO:self.gameLabelsArray[[labelNumber intValue]-1]];
                    [self.playerOMoves addObject:labelNumber];
                    self.didPlayerWin = [self.winConditionChecker checkWinConditions:self.playerOMoves];

                }
                else
                {
                    labelNumber = [self.winConditionChecker blockPlayerFromWinningTheGame:self.playerXMoves:self.playerOMoves];
                    if(labelNumber != nil)
                    {
                        [self changeLabelToO:self.gameLabelsArray[[labelNumber intValue]-1] ];
                        [self.playerOMoves addObject:labelNumber];
                        self.didPlayerWin = [self.winConditionChecker checkWinConditions:self.playerOMoves];
                    }
                    else
                    {
                        labelNumber = [self.winConditionChecker blockFork:self.playerXMoves:self.playerOMoves];
                        [self changeLabelToO:self.gameLabelsArray[[labelNumber intValue]-1]];
                        [self.playerOMoves addObject:labelNumber];
                        [self.playerOMoves addObject:labelNumber];
                        self.didPlayerWin = [self.winConditionChecker checkWinConditions:self.playerOMoves];
                        
                    }
                    
                    
                }
                
            }
            
        }
    }
    
}


- (void) changeLabelToO:(UILabel *)label
{
    label.text = [NSString stringWithFormat:@"O"];
    label.textColor = [UIColor redColor];
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

@end
