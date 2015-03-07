#!/usr/bin/env bash

#Pouziti: run_test	<1 vystup> <2 navratovy kod> <3 argumenty> <4 popis>
#<vystup> -  '': neporovnavej | jinak: porovnej s <vystup>
function run_test {
	((count++))

	printf ">>> %-7s %-59s " "Test$count" "$4"

	printf ""|$INTERPRETER $SCRIPT $3 1> "test.out" 2> "err.out"
	exit_code="$?"

	if [ "$1" = "" ]; then
		diffCode="0"; 
		diffout="";
	else
		diffout="Diffout\n"`diff "test.out" "$1"`"\n"
		diffCode=$?
	fi

	if [ "$diffCode" = "0" ] && [ "$exit_code" = "$2" ]; then
		echo -e "[  ${green}OK${NC}  ]"
		((ok_count++))
	else
		echo -e "[ ${red}FAIL${NC} ]"
		echo "$INTERPRETER" "$SCRIPT" "$3"
		cat "err.out"
		echo "Exit code: $exit_code"
		printf "%s" "$diffout"
		echo
	fi
	rm "test.out"
	rm "err.out"
}

SCRIPT="../ipp-dka/dka.py"
INTERPRETER="python3"

if [ `basename "$PWD"` != "ipp-dka-test" ]; then
	cd "../ipp-dka-test"
	if [ `basename "$PWD"` != "ipp-dka-test" ]; then
		echo "Spustte skript ve slozce s projektem nebo ve slozce s testy."
		exit 1
	fi
fi

ok_count=0
count=0

red='\033[1;31m'
green='\033[1;32m'
NC='\033[0m'

function check_ref_test {
	((count++))
	if [ "$1" -lt "10" ]; then
		num="0$1"
	else
		num="$1"
	fi


	printf ">>> %-10s %-56s " "RefTest$1" ""
	if [ -f test$num.txt ]; then
		diffOut="Diffout\n`diff "ref-st/test$num.out" "ref-out/test$num.out"`\n"
		retOut=$?
	else
		retOut="0"
	fi
	diffRet="DiffRet\n`diff ref-st/test$num'.!!!' ref-out/test$num'.!!!'`\n"
	retRet=$?
	if [ "$retOut" = "0" ] && [ "$retRet" = "0" ]; then
		echo -e "[  ${green}OK${NC}  ]"
		((ok_count++))
	else
		echo -e "[ ${red}FAIL${NC} ]"
		tail ref-st/test$num.err
		printf "%s" "$diffRet"
		echo
	fi
}

if [ ! -d "ref-st" ]; then
	mkdir "ref-st"
fi

TASK=../ipp-dka/dka
#INTERPRETER="php -d open_basedir=\"\""
#EXTENSION=php
INTERPRETER=python3
EXTENSION=py

# cesty ke vstupním a výstupním souborům
LOCAL_IN_PATH="./" # (simple relative path)
LOCAL_IN_PATH2="" #Alternative 1 (primitive relative path)
LOCAL_IN_PATH3=`pwd`"/" #Alternative 2 (absolute path)
LOCAL_OUT_PATH="./ref-st" # (simple relative path)
LOCAL_OUT_PATH2="ref-st" #Alternative 1 (primitive relative path)
LOCAL_OUT_PATH3="ref-st/" #Alternative 2 (absolute path)
# cesta pro ukládání chybového výstupu studentského skriptu
LOG_PATH="ref-st/"


# test01: mini definice automatu; Expected output: test01.out; Expected return code: 0
$INTERPRETER $TASK.$EXTENSION --input=${LOCAL_IN_PATH}test01.in --output=${LOCAL_OUT_PATH}test01.out --determinization 2> ${LOG_PATH}test01.err
echo -n $? > ${LOG_PATH}/test01.!!!

# test02: jednoducha determinizace (z prednasek); Expected output: test02.out; Expected return code: 0
$INTERPRETER $TASK.$EXTENSION --input=${LOCAL_IN_PATH}test02.in -d > ${LOCAL_OUT_PATH}test02.out 2> ${LOG_PATH}test02.err
echo -n $? > ${LOG_PATH}/test02.!!!

# test03: pokrocila determinizace; Expected output: test03.out; Expected return code: 0
$INTERPRETER $TASK.$EXTENSION -d --input=${LOCAL_IN_PATH}test03.in --output=${LOCAL_OUT_PATH}test03.out 2> ${LOG_PATH}test03.err
echo -n $? > ${LOG_PATH}/test03.!!!

# test04: diakritika a UTF-8 na vstupu; Expected output: test04.out; Expected return code: 0
$INTERPRETER $TASK.$EXTENSION < ${LOCAL_IN_PATH3}test04.in > ${LOCAL_OUT_PATH}test04.out 2> ${LOG_PATH}test04.err
echo -n $? > ${LOG_PATH}/test04.!!!

# test05: slozitejsi formatovani vstupniho automatu (specialni znaky); Expected output: test05.out; Expected return code: 0
$INTERPRETER $TASK.$EXTENSION --input=${LOCAL_IN_PATH}test05.in --output=${LOCAL_OUT_PATH}test05.out 2> ${LOG_PATH}test05.err
echo -n $? > ${LOG_PATH}/test05.!!!

# test06: vstup ze zadani; Expected output: test06.out; Expected return code: 0
$INTERPRETER $TASK.$EXTENSION -d --output=${LOCAL_OUT_PATH3}test06.out < ${LOCAL_IN_PATH}test06.in 2> ${LOG_PATH}test06.err
echo -n $? > ${LOG_PATH}/test06.!!!

# test07: odstraneni vymazavacich prechodu (priklad z IFJ04); Expected output: test07.out; Expected return code: 0
$INTERPRETER $TASK.$EXTENSION -e --input=${LOCAL_IN_PATH}test07.in --output=${LOCAL_OUT_PATH2}test07.out 2> ${LOG_PATH}test07.err
echo -n $? > ${LOG_PATH}/test07.!!!

# test08: Chybna kombinace parametru -e a -d; Expected output: test08.out; Expected return code: 1
$INTERPRETER $TASK.$EXTENSION --input=${LOCAL_IN_PATH}test08.in --output=${LOCAL_OUT_PATH3}test08.out -d --no-epsilon-rules 2> ${LOG_PATH}test08.err
echo -n $? > ${LOG_PATH}/test08.!!!

# test09: chyba vstupniho formatu; Expected output: test09.out; Expected return code: 40
$INTERPRETER $TASK.$EXTENSION --input=${LOCAL_IN_PATH2}test09.in --output=${LOCAL_OUT_PATH}test09.out 2> ${LOG_PATH}test09.err
echo -n $? > ${LOG_PATH}/test09.!!!

# test10: semanticka chyba vstupniho formatu (poc. stav neni v mnozine stavu); Expected output: test10.out; Expected return code: 41
$INTERPRETER $TASK.$EXTENSION --input=${LOCAL_IN_PATH3}test10.in --output=${LOCAL_OUT_PATH}test10.out 2> ${LOG_PATH}test10.err
echo -n $? > ${LOG_PATH}/test10.!!!

# test90: Bonus RUL - prepinac rules-only (bez rozsireni vraci chybu); Expected output: test90.out; Expected return code: 0
$INTERPRETER $TASK.$EXTENSION --input=${LOCAL_IN_PATH}test90.in --output=${LOCAL_OUT_PATH2}test90.out --rules-only 2> ${LOG_PATH}test90.err
echo -n $? > ${LOG_PATH}/test90.!!!

# test91: Bonus WCH - oddeleni elementu nejen carkami, ale i bilymi znaky, symboly nemusi byt v apostrofech (bez rozsireni vraci chybu); Expected output: test91.out; Expected return code: 0
$INTERPRETER $TASK.$EXTENSION --input=${LOCAL_IN_PATH3}test91.in --output=${LOCAL_OUT_PATH}test91.out --white-char 2> ${LOG_PATH}test91.err
echo -n $? > ${LOG_PATH}/test91.!!!

# test92:  Bonus RUL a WCH - slozitejsi formatovani -r a -w (bez rozsireni vraci chybu); Expected output: test92.out; Expected return code: 0
$INTERPRETER $TASK.$EXTENSION -w --input=${LOCAL_IN_PATH}test92.in -r --output=${LOCAL_OUT_PATH3}test92.out 2> ${LOG_PATH}test92.err
echo -n $? > ${LOG_PATH}/test92.!!!


echo
echo -e "${green}Referencni testy${NC}"
echo

array=(1 2 3 4 5 6 7 8 9 10 )
for i in "${array[@]}"
do
	check_ref_test $i
done

echo
echo -e "${green}Testy determinizace${NC}"
echo

run_test 'out/test1.out' "0" '-d --input=../ipp-dka-test/in/test1.in'	'Determinizace z prednasek'
run_test 'out/test2.out' "0" '-d --input=../ipp-dka-test/in/test2.in'	'Determinizace bez pravidel'
run_test 'out/test3.out' "0" '-d --input=../ipp-dka-test/in/test3.in'	'Determinizace s epsilon pravidly'

echo
echo -e "${green}Testy chyb ve vstupnim automatu${NC}"
echo

run_test 'out/test4.out' "40" '-d --input=../ipp-dka-test/in/test4.in'	'Chybi cilovy stav v pravidle'
run_test 'out/test5.out' "41" '-d --input=../ipp-dka-test/in/test5.in'	'Prazdna abeceda s pravidly'
run_test 'out/test6.out' "41" '-d --input=../ipp-dka-test/in/test6.in'	'Startujici stav neni mezi stavy'
run_test 'out/test7.out' "41" '-d --input=../ipp-dka-test/in/test7.in'	'Prazdna abeceda bez pravidel'
run_test 'out/test8.out' "41" '-d --input=../ipp-dka-test/in/test8.in'	'Koncovy stav neni mezi stavy'
run_test 'out/test9.out' "0" '-d --input=../ipp-dka-test/in/test9.in'		'Stejna pravidla budou ve vysledku jen jednou'
run_test 'out/test10.out' "0" '-d --input=../ipp-dka-test/in/test10.in'	'Stejne symboly v abecede'
run_test 'out/test11.out' "0" '-d --input=../ipp-dka-test/in/test11.in'	'Stejne stavy'
run_test 'out/test12.out' "0" '-d --input=../ipp-dka-test/in/test12.in'	'Skaredy komentar'
run_test 'out/test13.out' "0" '-d --input=../ipp-dka-test/in/test13.in'	'Apostrof jako znak abecedy'
run_test 'out/test14.out' "0" '-d --input=../ipp-dka-test/in/test14.in' 'Test diakritiky v abecede'

echo
echo -e "${green}Testy odstraneni e-pravidel${NC}"
echo

run_test 'out/test15.out' "0" '-e --input=../ipp-dka-test/in/test15.in' 'Jednoduche odstraneni e-pravidel'
run_test 'out/test16.out' "0" '-e --input=../ipp-dka-test/in/test16.in' 'Slozitejsi e-pravidla'

echo
echo -e "${green}Testy detailů${NC}"
echo

run_test 'out/test17.out' "40" '-e --input=../ipp-dka-test/in/test17.in' "Zadani '' jako znaku abecedy"
run_test 'out/test18.out' "40" '-e --input=../ipp-dka-test/in/test18.in' 'Identifikatory oddeleny pouze mezerou'
run_test 'out/test19.out' "0" '-e -i --input=../ipp-dka-test/in/test19.in' 'Test na case insensivity'

echo
echo -e "${red}Testy rozsireni STR${NC}"
echo

source "./test.sh"