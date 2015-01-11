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
            vc.isSinglePlayerEasy = false;
            vc.isSinglePlayerHard = false;
            vc.isMultiplayer = false;
            vc.isMPCMultiplayer = false;
            switch (button.tag)
            {
                case 0: vc.isSinglePlayerEasy = true;break;
                case 1: vc.isSinglePlayerHard = true;break;
                case 2: vc.isMultiplayer = true;break;
                case 3: vc.isMPCMultiplayer = true;break;
                default: break;
            }
        }
}

-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue
{
}


@end
