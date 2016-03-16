//
//  UINavigationBar+CustomImage.m
//  NewGPS
//
//  Created by TR on 13-5-24.
//  Copyright (c) 2013年 thinkrace. All rights reserved.
//

#import "UINavigationBar+CustomImage.h"
#import "UIImage+Scale.h"

@implementation UINavigationBar (CustomImage)

- (void)drawRect:(CGRect)rect
{
    UIImage *image = [[UIImage imageNamed:@"TRCOnline_1-5.png"] scaleToSize:CGSizeMake(320, 44)];
    [image drawInRect:CGRectMake(0,0,self.frame.size.width,self.frame.size.height)];
}


@end
