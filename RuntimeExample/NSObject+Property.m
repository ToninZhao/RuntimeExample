//
//  NSObject+Property.m
//  RuntimeExample
//
//  Created by ToninZhao on 2017/4/10.
//  Copyright © 2017年 ToninZhao. All rights reserved.
//

#import "NSObject+Property.h"
#import <objc/runtime.h>
@implementation NSObject (Property)
//getter
- (NSString *)objectName {
    return objc_getAssociatedObject(self, _cmd);
}

/**
 objc_AssociationPolicy policy: (枚举类型) ===>
 OBJC_ASSOCIATION_ASSIGN
 OBJC_ASSOCIATION_RETAIN_NONATOMIC
 OBJC_ASSOCIATION_COPY_NONATOMIC
 OBJC_ASSOCIATION_RETAIN
 OBJC_ASSOCIATION_COPY
 */
//setter
- (void)setObjectName:(NSString *)objectName {
    objc_setAssociatedObject(self, @selector(objectName), objectName, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
//私有方法
- (void)testPrivateMethod {
    NSLog(@"it is a private method");
}
//替换消息的接受者为其他对象
- (void)testMethodTarget {
    NSLog(@"testMethodTarget =======> %@", [self class]);
}
- (void)testMethodInvocation {
    NSLog(@"testMethodInvocation =======> %@", [self class]);
}
@end
