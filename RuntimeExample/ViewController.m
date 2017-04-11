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
@property (nonatomic, strong) NSObject *testObject;
@end

@implementation ViewController

/**
 在 load 加载类时,进行方法替换(经常用来覆盖'系统类'的'系统方法实现')
 */
+ (void)load {
    //class_getClassMethod 获取 '类方法'
    //class_getInstanceMethod 获取 '实例方法'
    Method method_one = class_getInstanceMethod(self, @selector(methodone));
    Method method_two = class_getInstanceMethod(self, @selector(methodtwo));
    method_exchangeImplementations(method_one, method_two);
    
    SEL originalSel = @selector(viewWillAppear:);
    SEL swizzledSel = @selector(tz_viewWillAppear:);
    
    Method originalMethod = class_getInstanceMethod([self class], originalSel);
    Method swizzledMethod = class_getInstanceMethod([self class], swizzledSel);
    
    BOOL didAddMethod = class_addMethod([self class], originalSel, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod([self class], swizzledSel, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}
- (void)tz_viewWillAppear:(BOOL)animated {
    [self tz_viewWillAppear:animated];
    NSLog(@"viewWillAppear: %@", self);
}
void testInstanceMethod(id self, SEL _cmd) {
    NSLog(@"the method ----> testInstanceMethod");
}

- (void)myInstanceMethod {
    NSLog(@"myInstanceMethod");
}
// 在'当前类'的方法列表里 找不到要调用的方法时,会调用 resolveInstanceMethod 此方法
// class_addMethod 为此类动态添加方法
+ (BOOL)resolveInstanceMethod:(SEL)sel {
    if (sel == @selector(testInstanceMethod)) {
        //方法1:
        //class_addMethod([self class], sel, (IMP)testInstanceMethod, "v@:");
        //方法2:
        class_addMethod([self class], sel, class_getMethodImplementation([self class], @selector(myInstanceMethod)), "v@:");
        return YES;
    }
    return [super resolveInstanceMethod:sel];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    /**
     IMP 指向实际执行函数体的函数指针
     Ivar Objective-C中的实例变量
     objc_selector 数据结构体 CString
     SEL -----> typedef struct objc_selector *SEL 映射到方法的C字符串;
     _cmd 表示当前调用方法，其实它就是一个方法选择器SEL。一般用于判断方法名或在Associated Objects中唯一标识键名
     */
        //1.objc_msgSend 调用方法
    objc_msgSend(self, @selector(test_msgSend));
    objc_msgSend(self, @selector(test_msgSendString:WithNumber:), @"abc", 2);
    
    //2.关联属性 ====> 给分类(特别是针对系统的类)动态添加属性
    NSObject *testObject = [NSObject new];
    self.testObject = testObject;
    testObject.objectName = @"testObjectProperty";
    NSLog(@"%@", testObject.objectName);
    
    //3.objc_msgSend 调用私有方法(有警告'找不到此方法')
    objc_msgSend(testObject, @selector(testPrivateMethod));
    //objc_msgSend 尝试调用'此类没有的方法',会 crash
    //objc_msgSend(testObject, @selector(noThisMethod));
    
    //4.method_exchangeImplementations 测试方法替换
    [self methodone];
    
    //5.当前对象调用的方法不在当前类的方法列表时,会依次调用以下3个方法:
    // =======> resolveInstanceMethod
    // =======> forwardingTargetForSelector
    // =======> forwardInvocation
    // 如果最后没找到对应的方法, crash
    // 在resolveInstanceMethod中, 可以为类的对象动态添加方法
    objc_msgSend(self, @selector(testInstanceMethod));
    
    //6.当resolveInstanceMethod返回 NO 时,继续执行forwardingTargetForSelector
    //在forwardingTargetForSelector中, 可以替换方法的接收者为 其他对象
    // self 调用 'testMethodTarget' 方法, 把 实现此方法的对象 self.testObject 替换为 self
    objc_msgSend(self, @selector(testMethodTarget));
    //7.当forwardingTargetForSelector返回的对象不响应调用的方法时, 继续执行forwardInvocation
    // 在forwardInvocation中, 可以替换方法的接收者为 其他对象
    objc_msgSend(self, @selector(testMethodInvocation));
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

//方法一
- (void)methodone {
    NSLog(@"first method");
}
//方法二
- (void)methodtwo {
    NSLog(@"second method");
}
- (id)forwardingTargetForSelector:(SEL)aSelector
{
    if(aSelector == @selector(testMethodTarget)){
        return self.testObject;
    }
    if (aSelector == @selector(testMethodInvocation)) {
        return self;
    }
    return [super forwardingTargetForSelector:aSelector];
}
- (void)forwardInvocation:(NSInvocation *)anInvocation {
    if ([[NSObject new] respondsToSelector:[anInvocation selector]]) {
        //重写方法签名
        [anInvocation invokeWithTarget:[NSObject new]];
    } else {
        [super forwardInvocation:anInvocation];
    }
}
@end
