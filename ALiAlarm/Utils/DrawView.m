//
//  DrawView.m
//  ALiAlarm
//
//  Created by 袁 章敬 on 14-6-19.
//  Copyright (c) 2014年 袁 章敬. All rights reserved.
//

#import "DrawView.h"
#import <QuartzCore/QuartzCore.h>
@implementation DrawView
@synthesize myColor = _myColor;
@synthesize shape = _shape;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    if (!_myColor) {
        _myColor = [UIColor blackColor];
    }
    switch (_shape) {
        case DrawShapeRect:{
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, _myColor.CGColor);
            CGContextFillRect(context, rect);
        }
        case DrawShapeCircle:{
            // Drawing code
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, _myColor.CGColor);
            CGContextFillEllipseInRect(context, rect);
        }
            break;
        case DrawShapeBubble:{
            // Drawing code
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetLineWidth(context, 2.0);//画笔线宽
            CGContextSetStrokeColorWithColor(context, _myColor.CGColor);
            CGContextSetFillColorWithColor(context, _myColor.CGColor);//填充颜色
            CGFloat radius = 6.0;
            
            CGFloat minx = CGRectGetMinX(rect);//得到rrect最左边的 x值
            CGFloat midx = CGRectGetMidX(rect);//得到rrect 横坐标x的中点值
            CGFloat maxx = CGRectGetMaxX(rect);//得到rrect 最右边的x值
            
            CGFloat miny = CGRectGetMinY(rect);//得到rrect y的最小值
            CGFloat maxy = CGRectGetMaxY(rect)-10;//得到rrect y的最大值－10
            
            //这是绘制的气泡下面的三角！
            CGContextMoveToPoint(context, midx+10, maxy);
            CGContextAddLineToPoint(context,midx, maxy+10);
            CGContextAddLineToPoint(context,midx-10, maxy);
            
            //绘制四个圆角
            CGContextAddArcToPoint(context, minx, maxy, minx, miny, radius); //左下角
            /*经测试 CGContextAddArcToPoint(CGContextRef c, CGFloat x1, CGFloat y1,
             CGFloat x2, CGFloat y2, CGFloat radius) 只是绘制 由currentPoint到 （x1,y1）之间的直线以及 分别与x1y1 和x2y2相切的一个半径为 radius的弧线。同时currentPoint 被设置成x2y2与圆弧的切点。*/
            
            
            CGContextAddArcToPoint(context, minx, minx, maxx, miny, radius); //左上角
            CGContextAddArcToPoint(context, maxx, miny, maxx, maxx, radius);
            CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
            
            //将路径闭合
            CGContextClosePath(context);
            CGContextFillPath(context);
        }
            break;
            
        default:
            break;
    }
}

@end
