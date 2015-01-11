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

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UIButton *)button
{
    if ([[segue.destinationViewController restorationIdentifier] isEqualToString:@"GameViewController"])
        {
            GameViewController *vc = segue.destinationViewController;
            vc.isSinglePlayerEasy = NO;
            vc.isMultiplayer = NO;
            vc.isMPCMultiplayer = NO;
            switch (button.tag)
            {
                case 0: vc.isSinglePlayerEasy = YES;break;
                case 1: vc.isSinglePlayerHard = YES;break;
                case 2: vc.isMultiplayer = YES;break;
                case 3: vc.isMPCMultiplayer = YES;break;
                default: break;
            }
        }
}

-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue
{
}


@end
