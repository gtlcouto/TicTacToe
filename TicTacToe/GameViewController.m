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
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UILabel *labelRow3Column3;
@property NSSet *allGameLabels;

@property (weak, nonatomic) IBOutlet UILabel *playerTurnLabel;
@property (strong, nonatomic) IBOutlet UILabel *winLabel;
@property (strong, nonatomic) IBOutlet UIView *buttonView;


@property NSUInteger remainingTicks;
@property WinConditionChecker *winConditionChecker;
@property (strong, nonatomic) IBOutlet UIButton *endedGameButton;

@property NSTimer *timeToPlay;

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
    self.playerXMoves = [[NSMutableSet alloc]init];
    self.playerOMoves = [[NSMutableSet alloc]init];
    self.winConditionChecker = [[WinConditionChecker alloc]initWithWinningConditionsSet];
    self.allGameLabels= [NSSet setWithObjects:self.labelRow1Column1,self.labelRow1Column2,self.labelRow1Column3,self.labelRow2Column1,self.labelRow2Column2,self.labelRow2Column3,self.labelRow3Column1, self.labelRow3Column2, self.labelRow3Column3,nil];
    [self createNewGame];
    self.timeToPlay = [NSTimer scheduledTimerWithTimeInterval: 1.0 target: self selector: @selector(handleTimerTick) userInfo: nil repeats: YES];


    
}

- (IBAction)tapHandler:(UITapGestureRecognizer *)gesture
{

    UILabel *labelTouched = [self findLabelUsingPoint: [gesture locationInView:self.buttonView]];
    NSLog(@"%li", (long)labelTouched.tag);
    NSString *labelTag = [NSString stringWithFormat:@"%li",(long)labelTouched.tag];

    if (!([self.playerXMoves containsObject:labelTag]  ||
        [self.playerOMoves containsObject:labelTag]) )
    {
        if (self.isMultiplayer)
        {
            if (self.isPlayerXTurn)
            {
                labelTouched.text = @"X";
                labelTouched.textColor = [UIColor blueColor];
                self.playerTurnLabel.text = @"O's turn";

                [self.playerXMoves addObject:labelTag];

                self.didPlayerWin = [self.winConditionChecker checkWinConditions:self.playerXMoves];
            } else
            {
                labelTouched.text = @"O";
                labelTouched.textColor = [UIColor redColor];
                [self.playerOMoves addObject:labelTag];
                self.playerTurnLabel.text = @"X's turn";
                self.didPlayerWin = [self.winConditionChecker checkWinConditions:self.playerOMoves];
            }
            //add to set
            //check set to subsets
            [self hasGameEnded];

            self.isPlayerXTurn = !self.isPlayerXTurn;

        }
        else //singleplayer
        {
                labelTouched.text = @"X";
                labelTouched.textColor = [UIColor blueColor];
                self.playerTurnLabel.text = @"O's turn";

                [self.playerXMoves addObject:labelTag];

                self.didPlayerWin = [self.winConditionChecker checkWinConditions:self.playerXMoves];

            [self hasGameEnded];

            self.isPlayerXTurn = !self.isPlayerXTurn;
            if(!self.didPlayerWin && !self.didGameDraw)
            {
                [self CPUMoves];
                [self hasGameEnded];
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
        self.timerLabel.text = [[NSNumber numberWithUnsignedInt: (int)self.remainingTicks] stringValue];

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
    for (UILabel *label in self.allGameLabels)
    {
        if (CGRectContainsPoint(label.frame, point) && label.tag != self.winLabel.tag)
        {
            return label;
        }
    }

    return [[UILabel alloc]init];

}

-(void)hasGameEnded
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
    NSLog(@"%li",(long)buttonIndex);
    switch (buttonIndex)
    {
        case 0: [self createNewGame];
    }
}

- (void) createNewGame

{
    for (UILabel *label in self.allGameLabels)
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

- (IBAction)prepareForUnwindSegue:(UIStoryboardSegue *)segue
{

}

- (void) CPUMoves
{
    NSMutableArray *availableSpaces = [[NSMutableArray alloc]init];
    for (UILabel *label in self.allGameLabels)
    {
        if ([label.text isEqualToString:@""] || !(label.text))
        {
            [availableSpaces addObject:[NSString stringWithFormat:@"%li", (long)label.tag]];
        }
    }
    if(availableSpaces.count > 0){
        NSUInteger randomIndex = arc4random() % [availableSpaces count];

        UILabel *selectedSpace = (UILabel *)[self.view viewWithTag:[[availableSpaces objectAtIndex:randomIndex] integerValue]];
        selectedSpace.text = [NSString stringWithFormat:@"O"];
        selectedSpace.textColor = [UIColor redColor];
        [self.playerOMoves addObject:[availableSpaces objectAtIndex:randomIndex]];
        self.didPlayerWin = [self.winConditionChecker checkWinConditions:self.playerOMoves];
    }

}




@end
