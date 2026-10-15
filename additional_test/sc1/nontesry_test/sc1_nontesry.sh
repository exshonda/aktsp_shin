#!/bin/sh

OS_PATH=../../../../../../../atk2-sc1
MAKE_OPT=

######################################################################
# 実行ファイル
#  -デバッガを使用するテストの場合，atk2-sc1.exeを指定すること
#  -デバッガを使用しないテストの場合，atk2-sc1.srecを指定すること
######################################################################
MODULE_NAME=atk2-sc1.exe
# MODULE_NAME=atk2-sc1.srec

######################################################################
# テスト一覧
######################################################################
 MANIFEST=debug.MANIFEST
# MANIFEST=nondebug.MANIFEST
# MANIFEST=run_and_debug.MANIFEST

######################################################################
# ログファイル
######################################################################
RESULT_MAKE_DEPEND=result_make_depend.log
RESULT_MAKE=result_make.log
RESULT_EXECUTE=result_execute.log

######################################################################
# 出力メッセージ
######################################################################
MAKE_DEPEND="make depend"
MAKE_BUILD="make"
MAKE_REALCLEAN="make realclean"
EXECUTE="exectue"
DEBUG="debug"

######################################################################
# デバッガコマンドスクリプト
######################################################################
DEBUG_COMMAND=gdb_cmd-nios2


make_depend()
{
	while read dir
	do
		cd $dir

		echo "$MAKE_DEPEND $dir"
		make depend &> $RESULT_MAKE_DEPEND

		cd ../../../
	done < $MANIFEST
}

make_build()
{
	while read dir
	do
		cd $dir

		echo "$MAKE_BUILD $dir"
		make $MAKE_OPT &> $RESULT_MAKE

		cd ../../../
	done < $MANIFEST
}

make_realclean()
{
	while read dir
	do
		cd $dir
		
		echo "$MAKE_REALCLEAN $dir"

		# ログファイル削除
		if [ -f "$RESULT_MAKE_DEPEND" ]
		then
			rm $RESULT_MAKE_DEPEND
		fi
		if [ -f "$RESULT_MAKE" ]
		then
			rm $RESULT_MAKE
		fi
		if [ -f "$RESULT_EXECUTE" ]
		then
			rm $RESULT_EXECUTE
		fi
		
		# reaclean
		make realclean > /dev/null

		cd ../../../
	done < $MANIFEST
}

execute()
{
	while read dir
	do
		cd $dir

		echo "$EXECUTE $dir"

		# 実行
		chk=`echo $MAKE_OPT | grep "SERIAL_UART=true" | wc -l`
		
		if [ $chk -eq 1 ]
		then
			# シリアル受信待機前に実行を開始しないよう，遅延してロードする
			cygstart --shownoactivate nios2-gdb-server.exe --cable=USB-Blaster $inst --no-verify -r --go --wait 2 $MODULE_NAME &
			sleep 1
		
			# teeだとログ受信が遅延したためscriptを使用する
			script -c "ruby $OS_PATH/target/nios2_dev_gcc/com_port.rb" $RESULT_EXECUTE
			grep --text -v "Script started on" $RESULT_EXECUTE > ./tmp
			grep --text -v "Script done" ./tmp > $RESULT_EXECUTE
		else
			nios2-gdb-server.exe --cable=USB-Blaster --no-verify -r --go $MODULE_NAME 1>&2 &
			expect -c "set timeout -1; spawn nios2-terminal --cable=USB-Blaster -q;
			expect \"Kernel Exit...\"; send \"\003\"" | tee  $RESULT_EXECUTE
		fi

		cd ../../../
	done < $MANIFEST
}

debug()
{
	while read dir
	do
		cd $dir

		echo "$DEBUG $dir"

		# 実行
		chk=`echo $MAKE_OPT | grep "SERIAL_UART=true" | wc -l`
		
		if [ $chk -eq 1 ]
		then
			echo "not support"
		else
			if [ -f "$DEBUG_COMMAND" ]
			then
				cygstart --shownoactivate nios2-gdb-server.exe --cable=USB-Blaster --tcpport=1234 -r&
				cygstart --shownoactivate nios2-terminal.exe --cable=USB-Blaster&
				nios2-elf-gdb.exe $MODULE_NAME -command ../../../nios2_gdb.ini
			fi
		fi
		cd ../../../
	done < $MANIFEST

}

# 実行するテストに合わせて修正して使用する
# make_realclean
make_depend
make_build
# execute
debug
