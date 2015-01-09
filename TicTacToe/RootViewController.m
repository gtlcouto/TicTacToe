//
//  ViewController.m
//  TicTacToe
//
//  Created by Diego Cichello on 1/8/15.
//  Copyright (c) 2015 Mobile Makers. All rights reserved.
//

#import "RootViewController.h"
#import "WinConditionChecker.h"

@interface RootViewController () <UIGestureRecognizerDelegate>
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

@property WinConditionChecker *winConditionChecker;

@property NSMutableSet *playerXMoves;
@property NSMutableSet *playerYMoves;

@property BOOL isPlayerXTurn;
@property BOOL gameEnded;


@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isPlayerXTurn = YES;
    self.playerXMoves = [[NSMutableSet alloc]init];
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

    if (![self.playerXMoves containsObject:labelTag]  &&
        ![self.playerYMoves containsObject:labelTag] )
    {




        if (self.isPlayerXTurn)
        {
            labelTouched.text = @"X";
            labelTouched.textColor = [UIColor blueColor];

            [self.playerXMoves addObject:labelTag];
            self.isPlayerXTurn = NO;
            self.playerTurnLabel.text = @"O's turn";
            self.gameEnded = [self.winConditionChecker checkWinConditions:self.playerXMoves];
        }
        else
        {
            labelTouched.text = @"O";
            labelTouched.textColor = [UIColor redColor];
            [self.playerYMoves addObject:labelTag];
            self.isPlayerXTurn = YES;
            self.playerTurnLabel.text = @"X's turn";
            self.gameEnded = [self.winConditionChecker checkWinConditions:self.playerYMoves];
        }

        if (self.gameEnded)
        {
            NSLog(@"GAME OVER");
        }
    }


}


#pragma Other Methods
// --------------------------------------- Other Methods ------------------------------------------

- (UILabel *)findLabelUsingPoint: (CGPoint)point
{
    for (UILabel *label in self.view.subviews)
    {
        if (CGRectContainsPoint(label.frame, point))
        {
            return label;
        }
    }

    return [[UILabel alloc]init];

}


@end
