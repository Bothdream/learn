function checknum2() {
    var=$1
	if [ -n "$var" -a "$var" = "${var//[^0-9]/}" ];then
		echo 0
	else
		echo 1
    fi	
}

function checknum1() {
	var=$1 
	if [ -z "$var" ]; then
       	echo 1
	elif [ -n "`echo $var | sed 's/[0-9]//g'`" ];then
       echo 1
    else
       echo 0
    fi	
}


function checknum() {
	var=$1
	expr $var + 1 &>/dev/null
	echo $?
}
res=`checknum2 $1`
echo $res

