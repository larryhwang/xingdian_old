//
//  RadioButton.m
//  NewGps2012
//
//  Created by TR on 13-4-11.
//  Copyright (c) 2013年 thinkrace. All rights reserved.
//

#import "RadioButton.h"

#define KRadioButtonWidth  22
#define KRadioButtonHeight 22

static NSMutableArray *rb_instances = nil;
static NSMutableDictionary *rb_observers = nil;

@implementation RadioButton

- (id)initWithGroupId:(NSString *)groupId index:(NSUInteger)index
{
    self = [self init];
    if (self) {
        self.groupId = groupId;
        self.index = index;
    }
    return  self;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self defaultInit];
    }
    return self;
}


- (void)defaultInit
{
    // Setup container view
    self.frame = CGRectMake(0, 0, KRadioButtonWidth, KRadioButtonHeight);
    
    // Customize UIButton
    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    _button.frame = CGRectMake(0, 0,KRadioButtonWidth, KRadioButtonHeight);
    _button.adjustsImageWhenHighlighted = NO;
    [_button setImage:[UIImage imageNamed:@"radioButton"] forState:UIControlStateNormal];
    [_button setImage:[UIImage imageNamed:@"radioButton-s"] forState:UIControlStateSelected];
    [_button addTarget:self action:@selector(handleButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_button];
    
    [RadioButton registerInstance:self];
}

#pragma mark - Manage Instances

+ (void)registerInstance:(RadioButton *)radioButton
{
    if (!rb_instances) {
        rb_instances = [[NSMutableArray alloc] init];
    }
    
    [rb_instances addObject:radioButton];
}

#pragma mark - Class level handler

+ (void)buttonSelected:(RadioButton *)radioButton
{
    // Notify observers
    if (rb_observers) {
        id observer= [rb_observers objectForKey:radioButton.groupId];
        
        if (observer && [observer respondsToSelector:@selector(radioButtonSelectedAtIndex:inGroup:)]) {
            [observer radioButtonSelectedAtIndex:radioButton.index inGroup:radioButton.groupId];
        }
    }
    
    // Unselect the other radio buttons
    if (rb_instances) {
        for (int i = 0; i < [rb_instances count]; i++) {
            RadioButton *button = [rb_instances objectAtIndex:i];
            if (![button isEqual:radioButton] && [button.groupId isEqualToString:radioButton.groupId]) {
                [button otherButtonSelected:radioButton];
            }
        }
    }
}

#pragma mark - Tap handling

- (void)handleButtonTap:(id)sender
{
    self.button.selected = YES;
    [RadioButton buttonSelected:self];
}

- (void)otherButtonSelected:(id)sender
{
    // Called when other radio button instance got selected
    if (_button.selected) {
        self.button.selected = NO;
    }
}

#pragma mark - Observer Interface

+ (void)addObserverForGroupId:(NSString*)groupId observer:(id)observer
{
    if(!rb_observers){
        rb_observers = [[NSMutableDictionary alloc] init];
    }
    
    if ([groupId length] > 0 && observer) {
        [rb_observers setObject:observer forKey:groupId];
    }
}

@end
