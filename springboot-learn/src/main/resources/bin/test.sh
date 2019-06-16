function is_unique_in_array(){
    array=$1

    array=${array[@]}
    element=$2

    for item in ${array[@]}
    do
        if test "$item" = "$element";then
            return 1
        fi
    done
    return 0
}


function main(){
    list=()
    e1='hh'
    e2='hhd'
    e3='hhhhd'

    is_unique_in_array "${list[@]}" "$e1"

    list=(${list[@]} $e1)

    is_unique_in_array "${list[@]}" "$e1"
}
 
main
