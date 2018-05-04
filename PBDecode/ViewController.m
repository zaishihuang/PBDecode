//
//  ViewController.m
//  PBDecode
//
//  Created by clovelu on 26/04/2018.
//

#import "ViewController.h"
#import "PBDecode.h"

@interface ViewController () <NSTextViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //self.inTextView.delegate = self;
    
    NSButton *button = [NSButton buttonWithTitle:@"button" target:self action:@selector(onTapButton:)];
    [self.view addSubview:button];
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}

- (void)onTapButton:(id)sender {
    NSLog(@"==> onTapButton");
//    NSString *hexString = @"0a260900 5006ef35 00360111 01a05d20 5ff85e08 1a123130 30363434 36353039 39333733 33363332 1202434e 19548766 9acd7c5c 40215a02 67fdd589 36402a03 343630";
    NSString *inputText = self.inTextView.string;
    NSData *data = [PBDecode dataForHexString:inputText];
    NSDictionary *info = [PBDecode parseFromData:data];
    
    NSString *outText = info ? info.description : @"";
    self.outTextView.string = outText;
    
    NSLog(@"==> info:%@", info);
    
}

#pragma mark -
#pragma mark NSTextViewDelegate
- (BOOL)textView:(NSTextView *)textView clickedOnLink:(id)link atIndex:(NSUInteger)charIndex {
    NSLog(@"==> onLink: %@", link);
    return YES;
}
@end
