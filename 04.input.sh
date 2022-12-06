#!/bin/bash

read -p "Enter your name : " name
echo "Your name = $name"

#Special Variable

#$0-$n , $* / $@, $#

echo Script Name = $0
echo First argument = $1
echo All Arguments = $*
echo Number of arguments = $#
