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
- (void)setObjectName:(NSString *)objectName {
    objc_setAssociatedObject(self, @selector(objectName), objectName, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (void)testPrivateMethod {
    NSLog(@"it is a private method");
}
@end
