#!/bin/bash
# Program:
# History:
# 2018/09/14	zch	First release

# 参考资料：
# 利用Shell脚本循环读取文件中每一行的方法详解[ https://www.jb51.net/article/122918.htm ]
# Shell编程之数组使用[ https://www.cnblogs.com/xudong-bupt/p/6138883.html ]
# Shell中脚本变量的作用域 [https://blog.csdn.net/abc86319253/article/details/46341839]
# awk引用外部变量[ https://www.cnblogs.com/mydomain/archive/2012/09/24/2699467.html ]

PATH=${PATH}
export PATH
LANG=en_US.utf8

####### 变量 start
declare -r sql_file_name='nginx-sql.sql'
declare -r summary_file_name='summary.txt'
declare -r default_location_name='-default-'


declare -r default_gateway_name='GATEWAY_SERVICE'
declare -r default_host_desc='description'

declare -r default_enable_balancing=1
declare -r default_need_auth=0
declare -r default_location_enable=0 #禁用
declare -r default_domain_name=''

####### 变量 end




# 字符串是否匹配正则
# 1 否；0 是
function is_string_match_regular(){
	str=$(echo "$1" | grep -ioE $2)
	if test -z "$str"
	then
		return 1
	else
		return 0
	fi
}


function to_lower(){
	lower_string=$1
	lower_string=`echo $lower_string|awk '{print tolower($0)}'`
}

function split(){
    split_string=$1
    split_char=$2

    split_array=()

    if test -z "$split_char";then
        split_array_len=$(echo ${split_string} | awk '{print NF}')

        for (( i=1; i<=$split_array_len; i=i+1 ))
        do
            temp_item=$(echo  ${split_string} | awk -v num=${i} '{print $num}')
            split_array=(${split_array[@]} "$temp_item")
        done
    else
        split_array_len=$(echo  ${split_string} | awk -v c=${split_char} 'BEGIN {FS=c} {print NF}')

        for (( i=1; i<=$split_array_len; i=i+1 ))
        do
            temp_item=$(echo  ${split_string} | awk -v num=${i} -v c=${split_char} 'BEGIN {FS=c} {print $num}')
            split_array=(${split_array[@]} "$temp_item")
        done

    fi
}

function is_unique_in_array(){
    array=($1)
    element=$2

    for item in ${array[@]}
    do
        if test "$item" = "$element";then
            return 1
        fi
    done
    return 0
}

# 获取下一行有效的数据
function get_next_line(){
	line_num=$(($line_num+1))
	if test $line_num -gt $line_count
	then
	    echo -e "warning, index out of bounds: [$line_num]-[$line_count]"
		line='error'
	else
		line=$(sed -n "${line_num}p" $filepath)

		# 判断是否空行或者是注释
		if test -z "$line"
		then
			get_next_line
		else
			first_char=$(echo  $line | awk '{print $1}')
			if test '#' = "$first_char"
			then
				get_next_line
			fi
		fi
	fi
	#echo -e "[$line_num]-[$line_count]:  $line"
}


function get_upstream_name(){
	upstream_name=$(echo  $line | awk '{print $2}')

	is_string_match_regular $upstream_name '{$'
	if test 0 -eq $?     #如果匹配到{,需要截取字符串
	then
	    upstream_name_len="${#upstream_name}"
		upstream_name=${upstream_name:0:$(($upstream_name_len-1))}
	fi

	if test -z $upstream_name;then
	    echo -e 'error,cannot get upstream name'
	    return 1
	fi
	return 0
}

function get_server_weight(){
    split "$line"

    temp_array=(${split_array[@]})
    for item in ${temp_array[@]}
    do
        is_string_match_regular "$item" '\bweight\b'
        if test 0 -eq $?;then
            split $item '='
            weight=${split_array[1]}
        fi

    done
}

function get_server_name(){
    server_name=$(echo  $line | awk '{print $2}')

	is_string_match_regular "$server_name" ';$'
	if test 0 -eq $?     #如果匹配到{,需要截取字符串
	then
	    server_name_len="${#server_name}"
		server_name=${server_name:0:$((server_name_len-1))}
	fi
	if test -z $server_name;then
	    echo -e "error,cannot get server name from line:[$line]"
	    return 1
	fi
	return 0
}

function get_server_location_name(){
    server_location_name=$(echo  $line | awk '{print $2}')

    is_string_match_regular "$server_location_name" '{$'
    if test 0 -eq $?     #如果匹配到{,需要截取字符串
	then
	    server_location_name_len="${#server_location_name}"
		server_location_name=${server_location_name:0:$(($server_location_name_len-1))}
	fi

	is_string_match_regular "$server_location_name" '/$'
    if test 0 -eq $?     #如果匹配到{,需要截取字符串
	then
	    server_location_name_len="${#server_location_name}"
		server_location_name=${server_location_name:0:$(($server_location_name_len-1))}
	fi

	is_string_match_regular "$server_location_name" '^/'
    if test 0 -eq $?     #如果匹配到{,需要截取字符串
	then
	    server_location_name_len="${#server_location_name}"
		server_location_name=${server_location_name:1:$(($server_location_name_len))}
	fi

    if test -z "$server_location_name";then
	    server_location_name=$default_location_name
	fi
	return 0
}

function get_proxy_pass_name(){
    proxy_pass_name=$(echo  $line | awk '{print $2}')
    is_string_match_regular "$proxy_pass_name" ';$'
    if test 0 -eq $?     #如果匹配到{,需要截取字符串
	then
	    proxy_pass_name_len="${#proxy_pass_name}"
		proxy_pass_name=${proxy_pass_name:0:$(($proxy_pass_name_len-1))}
	fi

    is_string_match_regular "$proxy_pass_name" '/$'
    if test 0 -eq $?     #如果匹配到{,需要截取字符串
	then
	    proxy_pass_name_len="${#proxy_pass_name}"
		proxy_pass_name=${proxy_pass_name:0:$(($proxy_pass_name_len-1))}
	fi


	is_string_match_regular "$proxy_pass_name" '^http://'
    if test 0 -eq $?     #如果匹配到{,需要截取字符串
	then
	    proxy_pass_name_len="${#proxy_pass_name}"
		proxy_pass_name=${proxy_pass_name:7:$(($proxy_pass_name_len-1))}
	fi

	if test -z "$proxy_pass_name";then
	    echo -e "error,cannot get proxy pass name from line:[$line]"
	    return 1
	fi
	return 0

}

# 0 是；1 不是
function is_server_line(){
	first_word=$(echo  $line | awk '{print $1}')

	to_lower $first_word

	if test $lower_string = 'server'
	then
		return 0
	fi
	return 1
}


function is_ip_hash(){
	is_string_match_regular "$line" "ip_hash"
	if test 0 -ne $?
	then
		return 1
	fi
	return 0
}

function is_server_name_line(){
    first_word=$(echo  $line | awk '{print $1}')

	to_lower $first_word

	if test "$lower_string" = 'server_name'
	then
		return 0
	fi
	return 1
}

function is_proxy_pass_line(){
    first_word=$(echo  $line | awk '{print $1}')

	to_lower $first_word

	if test $lower_string = 'proxy_pass'
	then
		return 0
	fi
	return 1
}


# 0 正常结束；1 异常结束;2 不处理
function get_upstream_infos(){

	is_string_match_regular "$line" '\bupstream\b'
	if test 0 -ne $?
	then
		# 没有匹配到
		return 2
	fi

	is_string_match_regular "$line" '{'
	if test 0 -ne $?
	then
		# 没有匹配到
		echo -e '[$line_num] syntax error near upstream {'
		return 1
	fi

	upstream_name=''
	get_upstream_name

	upstream_info_lines=()
	brace_num=1
	lbao=1 # 1轮询；2 ip_hash
	weight=1

	while test 0 -ne $brace_num
	do
	    upstream_info_line=''
		get_next_line
		if test "error" = "$line"
		then
			break
		fi

		is_server_line
		if test 0 -eq $?
		then
			upstream_info_line=$(echo  $line | awk '{print $2}')
			get_server_weight
			upstream_info_lines=(${upstream_info_lines[@]} "$upstream_info_line#$weight")
		fi

		is_ip_hash
		if test 0 -eq $?
		then
			lbao=2
		fi

		is_string_match_regular "$line" '{'
		if test 0 -eq $?
		then
			brace_num=$(($brace_num+1))
		fi

		is_string_match_regular "$line" '}'
		if test 0 -eq $?
		then
			brace_num=$(($brace_num-1))
		fi

	done

    echo -e "[$upstream_name]'s upstream info:"
	for item in ${upstream_info_lines[@]}
	do
		upstream_info="$upstream_name#$item#$lbao"
		upstream_infos=(${upstream_infos[@]} $upstream_info)
		echo -e "[$upstream_info]"
	done
	get_next_line
	return 0
}

function get_server_location_infos(){
    is_string_match_regular "$line" '\blocation\s*/(\w+/)?\s*{$'
    if test 0 -ne $?
	then
		# 没有匹配到
		return 2
	fi

	server_location_name=''
	get_server_location_name

	server_location_brace_num=1
	proxy_pass_name=""

    while test 0 -ne $server_location_brace_num
    do
        get_next_line
		if test "error" = "$line"
		then
			break
		fi

        is_proxy_pass_line
        if test 0 -eq $?
		then
			get_proxy_pass_name
			if test 0 -ne $?;then
			    return 1
			fi
		fi

        is_string_match_regular "$line" '{'
		if test 0 -eq $?
		then
			server_location_brace_num=$(($server_location_brace_num+1))
		fi

		is_string_match_regular "$line" '}'
		if test 0 -eq $?
		then
			server_location_brace_num=$(($server_location_brace_num-1))
		fi
    done

    location_info="$server_location_name#$proxy_pass_name"
    location_infos=(${location_infos[@]} "$location_info")

    get_next_line
    return 0
}

function get_http_server_infos(){
	is_string_match_regular "$line" '\bserver\s*{$'
	if test 0 -ne $?
	then
		# 没有匹配到
		return 2
	fi

	http_server_brace_num=1
	server_name=''
    location_infos=()


	while test 0 -ne $http_server_brace_num
	do
        flag_location=''
        get_next_line

	    if test "error" = "$line"
		then
		    echo -e "error,brace num :[$http_server_brace_num]"
			break
		fi

        is_server_name_line
        if test 0 -eq $?;then
            get_server_name
        fi


        while test "2" != "$flag_location"
        do
            get_server_location_infos
            flag_location=$?
            if test 1 -eq $flag_location;then
                return 1
            fi
        done


        is_string_match_regular "$line" '{'
		if test 0 -eq $?
		then
			http_server_brace_num=$(($http_server_brace_num+1))
		fi

		is_string_match_regular "$line" '}'
		if test 0 -eq $?
		then
			http_server_brace_num=$(($http_server_brace_num-1))
		fi
	done

	is_unique_in_array "${http_server_infos[@]}" "$server_name"

	if test 0 -eq $?;then
	    http_server_infos=(${http_server_infos[@]} $server_name)
	else
	    echo "warning, reduplicate server[${server_name}] in file[${filename}]"
	    get_next_line
	    return 0
	fi

    echo -e "[$server_name]'s server and location info:"
    for item in ${location_infos[@]}
	do
		server_location_info="$server_name#$item"
		server_location_infos=(${server_location_infos[@]} $server_location_info)

		echo -e "[$server_location_info]"
	done

	get_next_line
	return 0
}

function write_http_server_sql(){

    comments="-- -------------${server_name}---------${filename}---------------"
    server_sql="insert into c_host(host,gateway_id,host_desc,enable) select '${item_http_server}',cg.id,'${default_host_desc}','1' from c_gateway cg where cg.gateway_code = '${default_gateway_name}';"

    echo -e "" >> ${sql_file_name}
    echo -e "$comments" >> ${sql_file_name}
    echo -e "$server_sql" >> ${sql_file_name}
    echo -e "" >> ${sql_file_name}
}

function write_server_location_sql(){
    comments="-- [$item_location_count]-----------------${location_name}---------------"
    location_sql="insert into c_api_group (group_name, group_context, upstream_domain_name, upstream_service_id, enable_balancing, need_auth, lb_algo, enable, host_id) select '${location_name}', '${location_name}', '${default_domain_name}', '${location_name}', ${default_enable_balancing}, ${default_need_auth}, ${location_lbao}, ${default_location_enable},ch.id from c_host ch where ch.host='${server_name}';"

    echo -e "" >> ${sql_file_name}
    echo -e "$comments" >> ${sql_file_name}
    echo -e "$location_sql" >> ${sql_file_name}
    echo -e "" >> ${sql_file_name}
}

function write_ip_and_port_sql(){
    ip_and_port_sql="INSERT INTO c_group_target (group_id, host, port, weight) SELECT ap.id,'${ip}','${port}',${weight} FROM c_api_group ap JOIN c_host ch ON ap.host_id=ch.id WHERE ch.host='${server_name}' and ap.group_context='${location_name}';"
    echo -e "$ip_and_port_sql" >> ${sql_file_name}
}


function analyze_file(){
    get_next_line
	while test $line_num -lt $line_count
	do
		get_upstream_infos
		flag1=$?
		if test 1 -eq $flag1; then
		    echo -e "error,stop analyze file:[$filepath],line:[$line],line num:[$line_num]"
		    return 1
		fi


		get_http_server_infos
		flag2=$?
		if test 1 -eq $flag2; then
		    echo -e "error,stop analyze file:[$filepath],line:[$line],line num:[$line_num]"
		    return 1
		fi

		if test 2 -eq $flag1 && test 2 -eq $flag2;then
		    # 当既不属于upstream，也不属于http server的时候，取下一行
		    get_next_line
		fi
	done
}

function write_sql(){

    http_server_infos_len="${#http_server_infos[@]}"
    if test 0 -eq $http_server_infos_len;then
        echo -e "{error!}, no http server found,please check this configure file"
        return 1
    fi

    server_location_infos_len="${#server_location_infos[@]}"
    if test 0 -eq $server_location_infos_len;then
        echo -e "{error!}, no location found,please check this configure file"
        return 1
    fi

    upstream_infos_len="${#upstream_infos[@]}"
    if test 0 -eq $upstream_infos_len;then
        echo -e "{error!}, no upstream's ip+port found,please check this configure file"
        return 1
    fi

    echo -e ""
    echo -e "\t\ttotal number of http server :$http_server_infos_len"
    echo -e "\t\ttotal number of location :$server_location_infos_len"
    echo -e "\t\ttotal number of upstream's ip+port :$upstream_infos_len"
    echo -e ""

    item_http_server_count=0
    for item_http_server in ${http_server_infos[@]}
    do
        echo -e "[${item_http_server}] http server start..."

        item_http_server_count=$(($item_http_server_count+1))
        write_http_server_sql

        item_location_count=0
        for item_server_location in ${server_location_infos[@]}
        do
            split "$item_server_location" "#"

            server_name=${split_array[0]}
            location_name=${split_array[1]}
            proxy_pass_name=${split_array[2]}

            location_lbao=''
            if test "$server_name" = "$item_http_server";then
                echo -e "[$server_name]-[$location_name]  location  start..."

                item_location_count=$(($item_location_count+1))
                item_ip_and_port_count=0
                for item_upstream in ${upstream_infos[@]}
                do
                    split "$item_upstream" "#"

                    upstream_name=${split_array[0]}
                    ip_and_port=${split_array[1]}
                    weight=${split_array[2]}
                    lbao=${split_array[3]}

                    if test "$upstream_name" = "$proxy_pass_name";then
                        item_ip_and_port_count=$(($item_ip_and_port_count+1))

                        split "$ip_and_port" ":"
                        ip=${split_array[0]}
                        port=${split_array[1]}

                        echo -e "[$server_name]-[$location_name]-[$ip]:[$port]:[$weight]:[$lbao]  upstream info "

                        if test -z ${location_lbao};then
                            location_lbao=$lbao
                            write_server_location_sql
                        fi

                        write_ip_and_port_sql
                    fi
                done

                summary_location=(${summary_location[@]} "$server_name#$location_name#$item_ip_and_port_count")
                echo -e "[$server_name]-[$location_name]  location  end..."
            fi
        done

        summary_server=(${summary_server[@]} "$item_http_server#$item_location_count")

        echo -e "[${item_http_server}] http server end..."
    done

}

function summary_of_file(){
    http_server_count="${#http_server_infos[@]}"
    echo -e "\t\t\t SUMMARY OF [$filename]\r\n" >> ${summary_file_name}
    echo -e "\t\tthe number of http server: $http_server_count\r\n" >> ${summary_file_name}

    for item_http_server in ${http_server_infos[@]}
    do
        for item_server in ${summary_server[@]}
        do
            split "$item_server" "#"
            http_server_name=${split_array[0]}
            location_count=${split_array[1]}

            if test "$http_server_name" = "$item_http_server";then
                echo -e "\t\tthe number of [$http_server_name]'location: $location_count" >> ${summary_file_name}
            fi
        done

        for item_location in ${summary_location[@]}
        do
            split "$item_location" "#"
            http_server_name=${split_array[0]}
            location_name=${split_array[1]}
            ip_port_count=${split_array[2]}

            if test "$http_server_name" = "$item_http_server";then
                echo -e "\t\tthe number of [$location_name]'s ip/port: $ip_port_count" >> ${summary_file_name}
            fi
        done
        echo -e "" >> ${summary_file_name}
    done
    echo -e "---------------------------------------" >> ${summary_file_name}
}

function gen_sql_by_file(){
	filepath=$1

	if ! test -e $filepath || ! test -f $filepath
	then
		echo -e "$filepath dones't exit or is not a regular file,eixt 1"
		return 1
	fi


	line_num=0
	line_count=$(wc $filepath | awk '{print $1}')
	upstream_infos=()
	http_server_infos=()
	server_location_infos=()

	summary_server=()
	summary_location=()

	echo -e "-------------------------analyze [$filepath] start........-----------------------------"

    analyze_file
    if test 0 -ne $?;then
        echo -e "{error},happened when analyze [$filepath]"
        return 1
    fi

	echo -e "-------------------------analyze [$filepath] end........-----------------------------"


	echo -e "-------------------------write sql to file [$sql_file_name] start........-----------------------------"

    write_sql
    if test 0 -ne $?;then
        echo -e "{error},happened when write sql by [$filepath]"
        return 1
    fi

	echo -e "-------------------------write sql to file [$sql_file_name] end........-------------------------------"

    summary_of_file
	return 0

}


function gen_sql_by_path(){
	rootpath=$1

	filelist=$(ls $rootpath)
	if test 0 -ne $?;then
	    return 1
	fi

	echo -e "#########################################################################################"
	echo -e "files shown as bellow：\r\n"
	echo -e "$filelist"
	echo -e "#########################################################################################"


	for filename in $filelist
	do
		filepath="$rootpath/$filename"

		echo -e "++++++++++++[$filepath] start+++++++++++++++++++++++++++"
		gen_sql_by_file $filepath
        echo -e "++++++++++++[$filepath] end+++++++++++++++++++++++++++"
        echo -e "\r\n"
		if test 0 -ne $?;then
            continue
        fi

	done


    echo -e "\r\n"
    echo -e "see summaries: $(pwd)/${summary_file_name}"
    echo -e ""
	echo -e "\t\t                              THE END!                                                 "
}


echo -e "\t\t1. nginx conf files what you want to generate sql from should be saved in a folder without other files; "
echo -e "\t\t2. follow the program tips ：input this folder path -- no matter of full path or relative path;"
echo -e "\t\t3. after this program stops,check the file: $(pwd)/${sql_file_name}"
echo -e "\r\n"
read -p "the folder path: " path  # 提示使用者输入
gen_sql_by_path "$path"
exit 0