//
//  HtmlViewParser.m
//  html-layout-ios
//
//  Created by Jared Lewis on 8/17/12.
//  Copyright (c) 2012 Jared Lewis. All rights reserved.
//

#import "HtmlViewParser.h"
#import "HtmlViewController.h"
#import "TFHpple.h"
#import "TFHppleElement.h"
#import "UIColor+CreateMethods.h"
#import "UIFlexibleView.h"
#import "NSString+Util.h"

@implementation HtmlViewParser

@synthesize viewController;
@synthesize rootElement;
@synthesize rootView;

- (id)initWithViewController:(HtmlViewController *)htmlViewController
{
    self = [self init];
    if (self) {
        viewController = htmlViewController;
    }
    return self;
}

- (void)parse
{
    NSData *data = [NSData dataWithContentsOfFile:viewController.layoutPath];
//    NSLog(@"%@", data);
    TFHpple *doc = [[TFHpple alloc] initWithHTMLData:data];
    NSArray *elements = [doc searchWithXPathQuery:@"//body/view"];
    rootElement = [elements objectAtIndex:0];
    rootView = [self createViewFromElement:rootElement];
}

- (UIView *)createViewFromElement:(TFHppleElement *)element
{
    //Create the view from the views class attribute
    UIView *view = [[NSClassFromString([element objectForKey:@"class"]) alloc] init];
    
    //Apply the propery
    [self applyProperty:view fromElement:element];
    
    //Set the background color if necessary
    [self applyBackgroundColor:view fromElement:element];
    
    //Set the frame
    [self applyFrame:view fromElement:element];
    
    SEL processChildrenSelector = NSSelectorFromString([NSString stringWithFormat:@"processChildren:for%@:", [view class]]);
    if ([self respondsToSelector:processChildrenSelector]) {
        [self performSelector:processChildrenSelector withObject:element.children withObject:view];
    }
    
    //Return the view
    return view;
}

///////////////////////////////////////////////////
//  Apply Methods
//////////////////////////////////////////////////
- (void)applyProperty:(UIView *)view fromElement:(TFHppleElement *)element
{
    //Set the property
    NSString *property = [element objectForKey:@"property"];
    property = [property stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[property substringToIndex:1] uppercaseString]];
    NSString *selectorString = [NSString stringWithFormat:@"set%@:", property];
    SEL propertySelector = NSSelectorFromString(selectorString);
    if ([viewController respondsToSelector:propertySelector]) {
        [viewController performSelector:propertySelector withObject:view];
    }
}

- (void)applyBackgroundColor:(UIView *)view fromElement:(TFHppleElement *)element
{
    if ([element objectForKey:@"background-color"] == nil) {
        return;
    }
    
    UIColor *backgroundColor = [UIColor colorWithHex:[element objectForKey:@"background-color"] alpha:1.0f];
    [view setBackgroundColor:backgroundColor];
}

- (void)applyFrame:(UIView *)view fromElement:(TFHppleElement *)element
{
    CGRect frame = view.frame;
    
    // Apply width
    NSString *width = [element objectForKey:@"width"];
    if ([width contains:@"%"]) {
//      frame.size.width = [width floatValue] / 100 * rootView.frame.size.width;
    }
    else {
        frame.size.width = [(NSString *)[element objectForKey:@"width"] intValue];
    }
    frame.size.width = [(NSString *)[element objectForKey:@"width"] intValue];
    frame.size.height = [(NSString *)[element objectForKey:@"height"] intValue];
    frame.origin.x = [(NSString *)[element objectForKey:@"x"] intValue];
    frame.origin.y = [(NSString *)[element objectForKey:@"y"] intValue];
    [view setFrame:frame];
}

- (void)processChildren:(NSArray *)children forUIView:(UIView *)view
{
    // Process the children
    for (TFHppleElement *childElement in children) {
        UIView *childView = [self createViewFromElement:childElement];
        [view addSubview:childView];
    }
}

- (void)processChildren:(NSArray *)children forUIFlexibleView:(UIFlexibleView *)view
{
    // Process the children
    for (TFHppleElement *childElement in children) {
        UIView *childView = [self createViewFromElement:childElement];
        
        // Check for flex
        [view addItem:childView withFlex:1];
        if ([childElement objectForKey:@"flex"] != nil) {
            
        }
        
    }
}


@end
