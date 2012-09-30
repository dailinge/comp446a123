//
//  GraphViewController.m
//
//  Created by Linge Dai on 9/16/12.
//  Copyright (c) 2012 Rice. All rights reserved.
//

#import "GraphViewController.h"
#import "GraphView.h"
#import "CalculatorBrain.h"

@interface GraphViewController () <GraphViewDataSource>
@property (nonatomic, weak) IBOutlet GraphView *graphView;

@end

@implementation GraphViewController

@synthesize graphView = _graphView;

/* The model of the graph MVC */
@synthesize programDisplay = _programDisplay;
@synthesize graphBrain =_graphBrain;

/* Setter of the view. It initializes the gesture handlers */
- (void)setGraphView:(GraphView *)graphView
{
    _graphView = graphView;
    
    UIGestureRecognizer *recognizer;
    
    [self.graphView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pinch:)]];
    [self.graphView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pan:)]];
    
    recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(tripleTap:)];
    [(UITapGestureRecognizer *)recognizer setNumberOfTapsRequired:3];
    
    [self.graphView addGestureRecognizer:recognizer];

    self.graphView.dataSource = self;
}

/* Setter of the model */
- (void)setGraphBrain:(CalculatorBrain *)graphBrain
{
    _graphBrain = graphBrain;
    [self.graphView setNeedsDisplay];
}


/* Method in the graph datasource protocol to get the y value from the specific x value */
- (CGFloat)xForYValue:(CGFloat)x {
    NSDictionary *xValue = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:x], @"x", nil];
    
    id result = [CalculatorBrain runProgram:self.graphBrain.program usingVariableValues:xValue];
    
    if ([result isKindOfClass:[NSString class]]) {
        return 0;
    } else {
        return [result doubleValue];
    }

}

- (void)updateDescription
{
    self.programDisplay.text = [CalculatorBrain descriptionOfFirstProgram:self.graphBrain.program];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)viewDidUnload {
    [self setProgramDisplay:nil];
    [super viewDidUnload];
}
@end
