#!ruby
#
# AKTB
#      Automotive Kernel Test Builder
#
# Copyright (C) 2011-2014 by Center for Embedded Computing Systems
#             Graduate School of Information Science, Nagoya Univ., JAPAN
# Copyright (C) 2011-2014 by FUJI SOFT INCORPORATED, JAPAN
# Copyright (C) 2011-2013 by Spansion LLC, USA
# Copyright (C) 2011-2013 by NEC Communication Systems, Ltd., JAPAN
# Copyright (C) 2011-2014 by Panasonic Advanced Technology Development Co., Ltd., JAPAN
# Copyright (C) 2011-2014 by Renesas Electronics Corporation, JAPAN
# Copyright (C) 2011-2014 by Sunny Giken Inc., JAPAN
# Copyright (C) 2011-2014 by TOSHIBA CORPORATION, JAPAN
# Copyright (C) 2011-2014 by Witz Corporation, JAPAN
#
# 本ソフトウェアは，次世代車載システム向けRTOSの仕様検討及び開発に
# 関するコンソーシアム型共同研究において開発したものである．
# 本ソフトウェアの著作権は，上記の著作権者に帰属する．
# 
#  上記著作権者は，以下の(1)?(4)の条件を満たす場合に限り，本ソフトウェ
#  ア（本ソフトウェアを改変したものを含む．以下同じ）を使用・複製・改
#  変・再配布（以下，利用と呼ぶ）することを無償で許諾する．
#  (1) 本ソフトウェアをソースコードの形で利用する場合には，上記の著作
#      権表示，この利用条件および下記の無保証規定が，そのままの形でソー
#      スコード中に含まれていること．
#  (2) 本ソフトウェアを，ライブラリ形式など，他のソフトウェア開発に使
#      用できる形で再配布する場合には，再配布に伴うドキュメント（利用
#      者マニュアルなど）に，上記の著作権表示，この利用条件および下記
#      の無保証規定を掲載すること．
#  (3) 本ソフトウェアを，機器に組み込むなど，他のソフトウェア開発に使
#      用できない形で再配布する場合には，次のいずれかの条件を満たすこ
#      と．
#    (a) 再配布に伴うドキュメント（利用者マニュアルなど）に，上記の著
#        作権表示，この利用条件および下記の無保証規定を掲載すること．
#    (b) 再配布の形態を，別に定める方法によって，TOPPERSプロジェクトに
#        報告すること．
#  (4) 本ソフトウェアの利用により直接的または間接的に生じるいかなる損
#      害からも，上記著作権者およびTOPPERSプロジェクトを免責すること．
#      また，本ソフトウェアのユーザまたはエンドユーザからのいかなる理
#      由に基づく請求からも，上記著作権者およびTOPPERSプロジェクトを
#      免責すること．
#
#  本ソフトウェアは，AUTOSAR（AUTomotive Open System ARchitecture）仕
#  様に基づいている．上記の許諾は，AUTOSARの知的財産権を許諾するもので
#  はない．AUTOSARは，AUTOSAR仕様に基づいたソフトウェアを商用目的で利
#  用する者に対して，AUTOSARパートナーになることを求めている．
#
#  本ソフトウェアは，無保証で提供されているものである．上記著作権者お
#  よびTOPPERSプロジェクトは，本ソフトウェアに関して，特定の使用目的
#  に対する適合性も含めて，いかなる保証も行わない．また，本ソフトウェ
#  アの利用により直接的または間接的に生じたいかなる損害に関しても，そ
#  の責任を負わない．
#
# $Id: average_manifest.rb 347 2014-09-17 00:28:35Z fsi-dankei $
#

# シェルスクリプトでマニフェストファイルを平準化すると非常に
# 処理が重いため，Rubyで処理する

# ＜参考(シェルスクリプトで実現)＞
#	if [ "$ARG1" = "tt" ]
#	then
#		cnt=1
#		while [ $cnt -le $div_num ]
#		do
#			eval temp${cnt}=""
#			cnt=`expr $cnt + 1`
#		done

#		cnt=1
#		prg=1
#		ks_file_paths=`cat $temp_manifest`
#		for path in ${ks_file_paths[@]};
#		do
#			eval swp=\$temp${cnt}
#			swp="$swp $path"
#			eval temp${cnt}=\$swp
#			cnt=`expr $cnt + 1`
#			prg=`expr $prg + 1`
#			if [ $cnt -gt $div_num ]
#			then
#				cnt=1
#				per=`expr $prg '*' 100`
#				per=`expr $per / $all_step`
#				echo "$per% [$prg / $all_step]"
#			fi
#		done

#		rm -f $temp_manifest
#		cnt=1
#		while [ $cnt -le $div_num ]
#		do
#			eval paths=\$temp${cnt}
#			for path in ${paths[@]};
#			do
#				echo $path | tee -a $temp_manifest
#			done
#		done
#	fi

if (ARGV.size() != 2)
  exit 1
end

if (File.exist?(ARGV[0]))
  begin
    fLogFile = File.open(ARGV[0], "r")
  rescue
    exit 1
  end
else
  exit 1
end

if (ARGV[1].to_i() <= 0)
  exit 1
end

sFileName = ARGV[0]
nDivNum = ARGV[1].to_i()

sFileData = File.read(sFileName)
aData = sFileData.split("\n")

aTesry = []
(1..nDivNum).each{|nCnt|
  aTesry[nCnt] = []
}

nCnt = 1
aData.each{|sLine|
  aTesry[nCnt].push(sLine)
  nCnt += 1
  if (nCnt > nDivNum)
    nCnt = 1
  end
}

(1..nDivNum).each{|nCnt|
  aTesry[nCnt].each{|sLine|
    puts sLine
  }
}

exit 0
