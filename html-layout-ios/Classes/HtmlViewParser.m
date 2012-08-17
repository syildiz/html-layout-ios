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
     TFHpple *doc = [[TFHpple alloc] initWithHTMLData:data];
     NSArray *elements = [doc searchWithXPathQuery:@"//body/view"];
     rootElement = [elements objectAtIndex:0];
     //rootView = [self createViewFromElement:rootElement];
}

- (UIView *)createViewFromElement:(TFHppleElement *)element
{
    //Create the view from the views class attribute
    UIView *view = [[NSClassFromString([element objectForKey:@"class"]) alloc] init];
    
    //Set the property
    if ([element objectForKey:@"property"] != nil) {
        NSString *property = [element objectForKey:@"property"];
        property = [property stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[property substringToIndex:1] uppercaseString]];
        NSString *selectorString = [NSString stringWithFormat:@"set%@:", property];
        NSLog(@"%@", selectorString);
        SEL propertySelector = NSSelectorFromString(selectorString);
        if ([self respondsToSelector:propertySelector]) {
            [self performSelector:propertySelector withObject:view];
        }
    }
    
    //Set the background color if necessary
    if ([element objectForKey:@"background-color"] != nil) {
        UIColor *backgroundColor = [UIColor colorWithHex:[element objectForKey:@"background-color"] alpha:1.0f];
        [view setBackgroundColor:backgroundColor];
    }
    
    //Set the frame
    CGRect frame = view.frame;
    frame.size.width = [(NSString *)[element objectForKey:@"width"] intValue];
    frame.size.height = [(NSString *)[element objectForKey:@"height"] intValue];
    frame.origin.x = [(NSString *)[element objectForKey:@"x"] intValue];
    frame.origin.y = [(NSString *)[element objectForKey:@"y"] intValue];
    [view setFrame:frame];
    
    // Process the children
    for (TFHppleElement *childElement in element.children) {
        UIView *childView = [self createViewFromElement:childElement];
        [view addSubview:childView];
    }
    
    //Return the view
    return view;
}

@end
