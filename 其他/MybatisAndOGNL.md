Mybatis与OGNL

一、条件断言

- `b1 or b2` 条件 **或**
- `b1 and b2` 条件 **与**
- `!b1` 取反，也可以写作`not b1`
- `b1 == b2`,`b1 eq b2` 判断两个值相等
- `b1 != b2`,`b1 neq b2` 判断两个值不想等
- `b1 lt b2` 判断`b1`小于（less than）`b2`
- `b1 gt b2` 判断`b1`小于（greater than）`b2`
- `b1 lte b2`：判断`b1`小于等于`b2`
- `b1 gte b2`：判断`b1`大于等于`b2`
- `b1 in b2` 判断`b2`包含`b1`
- `b1 not in b2` 判断`b2`不包含`b1`

这些表达式经常和`test`配合。

二、四则运算

- `e1*e2` 乘法
- `e1/e2` 除法
- `e1-e2` 减法
- `e1%e2` 取模

三、类的内置方法

**Mybatis**的`Mapper.xml`中可以使用对象的内置方法。

```java
package cn.felord.util;

public final class CollectionUtils {
 public static boolean isNotEmpty( Collection<?> collection) {
  return (collection != null && !collection.isEmpty());
 }    
}
```

```xml
<if test="@cn.felord.util.CollectionUtils@isNotEmpty(collection)">
  and some_col = #{some_val}
</if>
```

注意：**这里要带上类的全限定名**

四、取值操作

```javascript
# 对象取属性
user.username
# 集合取元素
array[1] 
# map 取值
map['username']
```

五、赋值操作

```xml
 <where>
         <!-- 常用的赋值方式 -->
             username = #{username}
         <!-- $ 也可以赋值 -->
             and user_id =${userId}
         <!-- 对象取属性 -->
             and id = ${user.id}
         <!-- Math.abs  双@简写 -->
             and age = ${@@abs(-12345678)}
         <!-- 调用枚举 -->
             and gender =${@cn.felord.GenderEnum@MALE.ordinal()}
             and id=${@cn.felord.Cache@user.userId}
 </where>
```

注意：**枚举要带上类的全限定名**

