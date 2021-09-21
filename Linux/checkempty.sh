str1=$1
str2=$2
echo $str1
echo $str2
# 当两个串有相同内容、长度时为真 
if [ "$str1" = "$str2" ];then
	echo "str1 = str2 true"
else
    echo "str1 = str2 false"
fi
　　
# 当串str1和str2不等时为真 　　  
if [ "$str1" != "$str2" ];then
   echo "str1 != str2 true"
else
   echo "str1 != str2 false"
fi
　　　　
# 当串的长度大于0时为真(串非空) 　 
if [ -n "$str1" ];then
   echo "-n str1 true"
else
   echo "-n str1 false"
fi
　
# 当串的长度为0时为真(空串) 　　　 
if [ -z "$str1" ];then
   echo "-z str1 true"
else
   echo "-z str1 false"
fi
　　
# 当串str1为非空时为真　　　 
# 当串str1为非空时为真　　　 
if [ "$str1" ];then
   echo "str1 true"
else
   echo "str1 false"
fi