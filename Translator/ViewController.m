//
//  ViewController.m
//  Translator
//
//  Created by yclzone on 01/01/2018.
//  Copyright © 2018 YCLZONE. All rights reserved.
//

#import "ViewController.h"
#import "MTTranslator.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    MTScope scope = MTScopeTTS;
    [[MTTranslator sharedTranslator] allLanguageSupportedWithLanguage:@"zh" scope:scope completion:^(id data, NSError *error) {
        //
    }];
    
    
    
}

@end
