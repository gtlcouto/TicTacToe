//
//  RootViewController.m
//  TicTacToe
//
//  Created by Yi-Chin Sun on 1/8/15.
//  Copyright (c) 2015 Mobile Makers. All rights reserved.
//

#import "RootViewController.h"
#import "GameViewController.h"
#import "ConnectionsViewController.h"

@interface RootViewController ()
@property BOOL isMultiplayer;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)singlePlayerButtonTapped:(id)sender
{
    self.isMultiplayer = NO;
}
- (IBAction)multiplayerButtonTapped:(id)sender
{
    self.isMultiplayer = YES;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue.destinationViewController restorationIdentifier]  isEqual: @"connection"])
    {
        ConnectionsViewController *vc = segue.destinationViewController;
    } else {
        GameViewController *vc = segue.destinationViewController;
        vc.isMultiplayer = self.isMultiplayer;
    }


}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
