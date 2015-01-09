//
//  ViewController.m
//  TicTacToe
//
//  Created by Diego Cichello on 1/8/15.
//  Copyright (c) 2015 Mobile Makers. All rights reserved.
//

#import "RootViewController.h"
#import "WinConditionChecker.h"

@interface RootViewController () <UIGestureRecognizerDelegate, UIAlertViewDelegate>
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


@property NSUInteger remainingTicks;
@property WinConditionChecker *winConditionChecker;
@property (strong, nonatomic) IBOutlet UIButton *endedGameButton;

@property NSTimer *timeToPlay;

@property NSMutableSet *playerXMoves;
@property NSMutableSet *playerOMoves;

@property BOOL isPlayerXTurn;
@property BOOL didPlayerWin;


@end

@implementation RootViewController

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tapHandler:(UITapGestureRecognizer *)gesture
{

    UILabel *labelTouched = [self findLabelUsingPoint: [gesture locationInView:self.view]];
    NSLog(@"%li", (long)labelTouched.tag);
    NSString *labelTag = [NSString stringWithFormat:@"%li",(long)labelTouched.tag];

    if (!([self.playerXMoves containsObject:labelTag]  ||
        [self.playerOMoves containsObject:labelTag]) )
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
            [self.playerOMoves addObject:labelTag];
            self.playerTurnLabel.text = @"X's turn";
            self.didPlayerWin = [self.winConditionChecker checkWinConditions:self.playerOMoves];
        }



        [self hasGameEnded:self.didPlayerWin];

        if (!self.didPlayerWin && (self.playerOMoves.count + self.playerXMoves.count) == 9)
        {
            [self hasGameEndedAsDraw];
        }
        self.isPlayerXTurn = !self.isPlayerXTurn;
        self.remainingTicks = 31;
        self.timeToPlay = [NSTimer scheduledTimerWithTimeInterval: 1.0 target: self selector: @selector(handleTimerTick) userInfo: nil repeats: NO];

    }


}

- (void) changePlayer
{
    if (self.isPlayerXTurn)
    {

        self.playerTurnLabel.text = @"O's turn";
    }
}


-(void)handleTimerTick
{
    if (!self.didPlayerWin)
    {
        self.remainingTicks--;
        self.timerLabel.text = [[NSNumber numberWithUnsignedInt: self.remainingTicks] stringValue];

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

-(void)hasGameEnded:(BOOL)gameEndedFlag
{
    UIAlertView *gameEndedAlertView = [[UIAlertView alloc]init];
    gameEndedAlertView.delegate = self;
    [gameEndedAlertView addButtonWithTitle: @"Play Again?"];

    if (gameEndedFlag && self.isPlayerXTurn)
    {
        gameEndedAlertView.title = [NSString stringWithFormat:@"Player X Wins!"];
        [gameEndedAlertView show];
    }
    else if (gameEndedFlag)
    {
        gameEndedAlertView.title = [NSString stringWithFormat:@"Player O Wins!"];
        [gameEndedAlertView show];

    }


}

-(void)hasGameEndedAsDraw
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
    self.remainingTicks = 31;



}

- (IBAction)prepareForUnwindSegue:(UIStoryboardSegue *)segue
{

}




@end
