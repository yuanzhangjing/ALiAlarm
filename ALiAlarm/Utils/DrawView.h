//
//  DrawView.h
//  ALiAlarm
//
//  Created by 袁 章敬 on 14-6-19.
//  Copyright (c) 2014年 袁 章敬. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, DrawShape) {
    DrawShapeRect = 0,
    DrawShapeRoundRect,
    DrawShapeCircle,
    DrawShapeBubble
};

@interface DrawView : UIView

@property (strong,nonatomic) UIColor *myColor;
@property (nonatomic,assign) DrawShape shape;
@end
