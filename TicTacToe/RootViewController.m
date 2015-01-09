//
//  RootViewController.m
//  TicTacToe
//
//  Created by Yi-Chin Sun on 1/8/15.
//  Copyright (c) 2015 Mobile Makers. All rights reserved.
//

#import "RootViewController.h"
#import "GameViewController.h"

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
if ([[segue.destinationViewController restorationIdentifier] isEqualToString:@"GameViewController"])
    {
        GameViewController *vc = segue.destinationViewController;
        vc.isMultiplayer = self.isMultiplayer;
    }
}

-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue
{
}


@end
