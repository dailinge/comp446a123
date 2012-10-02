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
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;

@end

@implementation GraphViewController

@synthesize graphView = _graphView;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;

/* The model of the graph MVC */
@synthesize toolBar = _toolBar;
@synthesize graphBrain =_graphBrain;

- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    if (_splitViewBarButtonItem != splitViewBarButtonItem) {
        NSMutableArray *toolbarItems = [self.toolBar.items mutableCopy];
        if (_splitViewBarButtonItem) [toolbarItems removeObject:_splitViewBarButtonItem];
        if (splitViewBarButtonItem) [toolbarItems insertObject:splitViewBarButtonItem atIndex:0];
        self.toolBar.items = toolbarItems;
        _splitViewBarButtonItem = splitViewBarButtonItem;
    }
}
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
    self.navigationItem.title = [CalculatorBrain descriptionOfFirstProgram:self.graphBrain.program];

}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)viewDidUnload {
    [self setToolBar:nil];
    [super viewDidUnload];
}
@end
