//
//  GraphViewController.h
//
//  Created by Linge Dai on 9/16/12.
//  Copyright (c) 2012 Rice. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "CalculatorBrain.h"
#import "SplitViewBarButtonPresenter.h"

@interface GraphViewController : UIViewController <SplitViewBarButtonPresenter>
@property (nonatomic) CalculatorBrain *graphBrain;
@end
