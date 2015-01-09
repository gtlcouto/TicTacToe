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
@property (weak, nonatomic) IBOutlet UILabel *labelRow3Column3;

@property (weak, nonatomic) IBOutlet UILabel *playerTurnLabel;
@property (strong, nonatomic) IBOutlet UILabel *winLabel;

@property WinConditionChecker *winConditionChecker;
@property (strong, nonatomic) IBOutlet UIButton *endedGameButton;

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

            [self.playerXMoves addObject:labelTag];
            self.playerTurnLabel.text = @"O's turn";
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
        self.isPlayerXTurn = !self.isPlayerXTurn;

    }


}


#pragma Other Methods
// --------------------------------------- Other Methods ------------------------------------------

- (UILabel *)findLabelUsingPoint: (CGPoint)point
{
    for (UILabel *label in self.view.subviews)
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




@end
