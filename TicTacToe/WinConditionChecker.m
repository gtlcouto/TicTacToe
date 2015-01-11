//
//  WinningCondition.m
//  TicTacToe
//
//  Created by Diego Cichello on 1/8/15.
//  Copyright (c) 2015 Mobile Makers. All rights reserved.
//

#import "WinConditionChecker.h"



@interface WinConditionChecker  ()

@property NSSet *winningCondition1;
@property NSSet *winningCondition2;
@property NSSet *winningCondition3;
@property NSSet *winningCondition4;
@property NSSet *winningCondition5;
@property NSSet *winningCondition6;
@property NSSet *winningCondition7;
@property NSSet *winningCondition8;
@property NSSet *allConditions;

@end

@implementation WinConditionChecker


- (WinConditionChecker *) initWithWinningConditionsSet
{
    self.winningCondition1 = [NSSet setWithObjects:@"1",@"2",@"3",nil];
    self.winningCondition2 = [NSSet setWithObjects:@"4",@"5",@"6",nil];
    self.winningCondition3 = [NSSet setWithObjects:@"7",@"8",@"9",nil];
    self.winningCondition4 = [NSSet setWithObjects:@"1",@"4",@"7",nil];
    self.winningCondition5 = [NSSet setWithObjects:@"2",@"5",@"8",nil];
    self.winningCondition6 = [NSSet setWithObjects:@"3",@"6",@"9",nil];
    self.winningCondition7 = [NSSet setWithObjects:@"1",@"5",@"9",nil];
    self.winningCondition8 = [NSSet setWithObjects:@"3",@"5",@"7",nil];
    self.allConditions = [NSSet setWithObjects:
                                        self.winningCondition1, self.winningCondition2,
                                        self.winningCondition3, self.winningCondition4,
                                        self.winningCondition5, self.winningCondition6,
                                        self.winningCondition7, self.winningCondition8, nil];

    return self;




};




- (BOOL) checkWinConditions: (NSSet *) currentSet
{

    
    for (NSSet *set in self.allConditions)
    {
        if ([set isSubsetOfSet:currentSet])
        {
            return YES;
        }
    }
    return NO;
}

- (NSString *) tryToWinTheGame:(NSSet *) playerXSet
                              :(NSSet *) playerOSet
{
    int numberOfNumbersMissing =0;
    NSMutableArray *numbersMissing = [[NSMutableArray alloc]init];


    for (NSSet *set in self.allConditions)
    {
       for (NSString *number in set)
       {
           if (![playerOSet containsObject:number])
           {
               numberOfNumbersMissing++;
               [numbersMissing addObject:number];
           }
       }

        if (numberOfNumbersMissing == 1)
        {
            if (![playerXSet containsObject:numbersMissing[0]])
            {
                return [numbersMissing objectAtIndex:0];
            }
        }
        numbersMissing = [[NSMutableArray alloc]init];
        numberOfNumbersMissing =0;
    }

    return nil;


}

- (NSString *) blockPlayerFromWinningTheGame:(NSSet *) playerXSet
                                            set2:(NSSet *) playerOSet
{
    int numberOfNumbersMissing =0;
    NSMutableArray *numbersMissing = [[NSMutableArray alloc]init];


    for (NSSet *set in self.allConditions)
    {
        for (NSString *number in set)
        {
            if (![playerXSet containsObject:number])
            {
                numberOfNumbersMissing++;
                [numbersMissing addObject:number];
            }
        }

        if (numberOfNumbersMissing == 1)
        {
            if (![playerOSet containsObject:numbersMissing[0]])
            {

                return [numbersMissing objectAtIndex:0];
            }
        }

        numbersMissing = [[NSMutableArray alloc]init];
        numberOfNumbersMissing =0;
    }
    
    return nil;

}

- (NSString *) blockFork:(NSSet *) playerXSet
                    set2:(NSSet *) playerOSet
{
    int numberOfNumbersMissing =0;
    NSMutableArray *numbersMissing = [[NSMutableArray alloc]init];
    NSMutableArray *linesWithForkConditions =  [[NSMutableArray alloc]init];


    for (NSSet *set in self.allConditions)
    {
        for (NSString *number in set)
        {
            if (![playerXSet containsObject:number])
            {
                numberOfNumbersMissing++;
                [numbersMissing addObject:number];

            }
        }

        if (numberOfNumbersMissing == 2)
        {
            [linesWithForkConditions addObject:set];
        }

        numbersMissing = [[NSMutableArray alloc]init];
        numberOfNumbersMissing =0;
    }
    
    for (NSSet *set in linesWithForkConditions)
    {
        for (NSSet *testedSet in linesWithForkConditions)
        {
            if (![set isEqual:testedSet])
            {
                if ([set intersectsSet:testedSet])
                {
                    for (NSString *number in testedSet)
                    {
                        if ([testedSet containsObject:number])
                        {
                            if ([playerXSet containsObject:@"1"] && [playerXSet containsObject:@"9"])
                            {
                                return @"8";

                            }
                            if ([playerXSet containsObject:@"7"] && [playerXSet containsObject:@"3"])
                            {
                                return @"2";

                            }
                            if (![playerXSet containsObject:number] && ![playerOSet containsObject:number]&& [set containsObject:number])
                            {
                                return number;
                            }
                        }

                    }
                }
            }
        }
    }
    return  nil;
}

- (void) doAFork
{
    
}

@end
