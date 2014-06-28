//
//  ProgressView.m
//  ALiAlarm
//
//  Created by 袁 章敬 on 14-6-21.
//  Copyright (c) 2014年 袁 章敬. All rights reserved.
//

#import "ProgressView.h"

@implementation ProgressView
@synthesize degree = _degree;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}
-(void)setDegree:(CGFloat)degree{
    //set degree and update progressview
    _degree = degree;
    
    [self setNeedsDisplay];
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGFloat linewidth = 40.0f;
    CGFloat w = CGRectGetWidth(rect);
    CGFloat h = CGRectGetHeight(rect);
    
    CGPoint center = CGPointMake(CGRectGetMidX(rect), -h);
    CGFloat r = w-linewidth;
    double start = M_PI*2/3;
    double end = M_PI/3;
    double by = _degree>=1?end:start-_degree*M_PI/3;
    // Drawing code
    UIBezierPath *backCircle = [UIBezierPath bezierPathWithArcCenter:center
                                                              radius:r
                                                          startAngle:start
                                                            endAngle:end
                                                           clockwise:NO];
    [[UIColor lightGrayColor] setStroke];
    backCircle.lineWidth = linewidth;
    [backCircle stroke];
    
        //draw progress circle
    UIBezierPath *progressCircle = [UIBezierPath bezierPathWithArcCenter:center
                                                                      radius:r
                                                                  startAngle:start
                                                                    endAngle:by
                                                                   clockwise:NO];
    [[UIColor blueColor] setStroke];
    progressCircle.lineWidth = linewidth;
    [progressCircle stroke];
}


@end
