//
//  ViewController.m
//  RuntimeExample
//
//  Created by ToninZhao on 2017/4/10.
//  Copyright © 2017年 ToninZhao. All rights reserved.
//

#import "ViewController.h"
#import "NSObject+Property.h"
#import <objc/message.h>
#import <objc/objc.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //1.objc_msgSend 调用方法
    objc_msgSend(self, @selector(test_msgSend));
    objc_msgSend(self, @selector(test_msgSendString:WithNumber:), @"abc", 2);
    //2.关联属性 ====> 给分类(特别是针对系统的类)动态添加属性
    NSObject *testObject = [NSObject new];
    testObject.objectName = @"testObjectProperty";
    NSLog(@"%@", testObject.objectName);
    //3.objc_msgSend 调用私有方法(有警告'找不到此方法')
    objc_msgSend(testObject, @selector(testPrivateMethod));
    //objc_msgSend 尝试调用'此类没有的方法',会 crash
    //objc_msgSend(testObject, @selector(noThisMethod));
    //
}

/**
 objc_msgSend 消息发送(oc 对应的"调用方法")
 现在 Xcode 编译器默认设置'objc_msgSend'不能发送带参数的消息, 需要改设置
 Build Setting ===> Apple LLVM '版本号' - Preprocessing ===> Enable Strict Checking of objc_msgSend Calls  改为 NO
 */
- (void)test_msgSend {
    NSLog(@"test_msgSend");
}
- (void)test_msgSendString:(NSString *)str WithNumber:(int)num {
    NSLog(@"test_msgSend ====> %@ , %d", str, num);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
