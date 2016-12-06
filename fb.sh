#!/usr/bin/env bash
#
# Made by Valeriy Kireev <valeriykireev@gmail.com>, 2016
#
# Use and modify code freely.
# Leave my name here, please.
#
# fb -- Flappy Bird clone written in GNU sed.
# 
# Implemented:
#  * Collisions;
#  * Level generation;
#  * Column's movement;
#  * User's input handling;
#  * Score counting.
#
# Not implemented:
#  * Bird's movement;
#  * Level randomization;
#  * Background music (?)
# 
# Move up with `k` button. No more movements implemented. It's original way,
#
# Problems:
#  * `read` on Solaris can't take floating-point timeout (-t) argument. 
#    Setting it to 1 second makes game slowly. TODO: Find way to fix it.
#  * On Linux you have to put `gsed` binary (or link to GNU sed) in $PATH.
#

field="[======================================]
[..............................========]
[..............................========]
[..............................========]
[..............................========]
[..............................========]
[..............................========]
[......................................]
[......................................]
[......................................]
[...........0..........................]
[......................................]
[......................................]
[..............................========]
[..............................========]
[..............................========]
[..............................========]
[..............................========]
[..............................========]
[======================================]
Score: 0"

running=1
while [ "1" == "${running}" ]
do
    clear
    echo "${field}"
    running=`echo "$field" | gsed -nr \
    '
        # Collisions
        : begin
        /^\[.{11}[.=]=/ {
            N
            /\n\[[.]{11}[1-9]/ b fail
            s/^.*\n(.*)$/\1/
            t begin
        }
        /^\[[.]{11}[0-9]=/ b fail
        /^\[[.]{11}0/ {
            N
            s/\n.{12}=/&/
            t fail
        }
        b not_fail
        : fail
        s/^.*$/0/p
        : not_fail
        $ s/^.*$/1/p
    '`

    field=`echo "$field" | gsed -r \
    '
        /^\[/{
            s/\.(={1,7}\])$/=\1/
            t border
            s/\.(=+\.)/\1./
            s/\.(=+)\]/\1.]/
            : border
            s/^\[=\./[../
            s/^(\[={1,7})=([^=].*)/\1.\2/
        }
        2,7 {
            /^\[={6}\.*\]/ s/\.\]/=]/
        }
        14,19 {
            /^\[={6}\.*\]/ s/\.\]/=]/
        }
        # Bird
        /^\[\.*[1-9].*/{
            y/123456789/012345678/
        }
        # Score
        19{
            /^\[[.]{3}=/! b inc_end
            N
            N
            t inc_9
            : inc_9
            s/9(x*)$/x\1/
            t inc_9
            s/ (x*)$/ 1\1/; t inc_fin
            s/0(x*)$/1\1/; t inc_fin
            s/1(x*)$/2\1/; t inc_fin
            s/2(x*)$/3\1/; t inc_fin
            s/3(x*)$/4\1/; t inc_fin
            s/4(x*)$/5\1/; t inc_fin
            s/5(x*)$/6\1/; t inc_fin
            s/6(x*)$/7\1/; t inc_fin
            s/7(x*)$/8\1/; t inc_fin
            s/8(x*)$/9\1/; t inc_fin
            : inc_fin
            s/x/0/;
            t inc_fin
        }
        : inc_end
    '`
    key=''
    # Timeout = 0.8 for Linux. s/0\.8/1/ for Solaris.
    read -s -t 0.8 -n1 key
    field=`echo -e "${key}\n${field}" | gsed -r \
    '
        1 {
            /k/! b print_all
            h
            N
            s/^.*\n(.*)$/\1/
        }
        2,$ {
            x
            /k/! bn
            x
            s/^(\[\.{11})[0-9]/\15/
            b
            :n
            x
        }
        : print_all
        1 {
            N
            s/^.*\n(.*)$/\1/
        }
    '`
done
echo "Game Over"
