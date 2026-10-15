#!ruby
#
#  TOPPERS ATK2
#      Toyohashi Open Platform for Embedded Real-Time Systems
#      Automotive Kernel Version 2
#
#  Copyright (C) 2011-2014 by Center for Embedded Computing Systems
#              Graduate School of Information Science, Nagoya Univ., JAPAN
#  Copyright (C) 2011-2014 by FUJISOFT INCORPORATED, JAPAN
#  Copyright (C) 2011-2013 by Spansion LLC, USA
#  Copyright (C) 2011-2013 by NEC Communication Systems, Ltd., JAPAN
#  Copyright (C) 2011-2014 by Panasonic Advanced Technology Development Co., Ltd., JAPAN
#  Copyright (C) 2011-2014 by Renesas Electronics Corporation, JAPAN
#  Copyright (C) 2011-2014 by Sunny Giken Inc., JAPAN
#  Copyright (C) 2011-2014 by TOSHIBA CORPORATION, JAPAN
#  Copyright (C) 2011-2014 by Witz Corporation, JAPAN
#
#  上記著作権者は，以下の(1)~(4)の条件を満たす場合に限り，本ソフトウェ
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
#  $Id: com_port.rb 104 2014-07-01 07:16:52Z ksigihar $
#

# 要インストール：$ gem install serialport
require "rubygems"
require "serialport"

Thread.abort_on_exception = true

# 引数: ログファイルパス
if (ARGV.size() == 1)
  sLogFile = ARGV[0]
else
  puts("[Error] No argument.")
  exit(1)
end


# ctrl+cによる強制終了設定
Signal.trap(:SIGINT){
  system("kill -9 #$$")
}


# ポート判定
aPorts = []
thSearchPort = Thread.new {
  IO.popen("ls -1 /dev/ttyS* | awk -F 'ttyS' '{print $2}' | sort -n") do |io|
    while io.gets()
      aPorts.push($_.gsub!("\n", "").to_i())
    end
  end
}
thSearchPort.join()

# COMポートが存在しない場合は終了
if (aPorts.empty?())
  puts("[Error] COM port is not found.")
  exit(1)
end

# 1番大きいポートが対象
nTargetPort = aPorts[-1]

# USBを挿した直後への対応
sChk = ""
thUSB = Thread.new {
  while true
    IO.popen("stty -F /dev/ttyS#{nTargetPort}") do |io|
      while io.gets()
        sChk = $_
      end
    end
    if (!sChk.include?("Invalid argument"))
      break
    end
  end
}
thUSB.join()


cCom = nil
nBaudrate = 115200
sLogData = ""
thMain = Thread.new {
  puts("\nUsing COM port: #{(nTargetPort+1).to_s()} [#{nBaudrate.to_s()}]")

  begin
    cCom = SerialPort.open("/dev/ttyS#{nTargetPort}", nBaudrate, 8, 1, SerialPort::NONE)
  rescue
    puts("use default baudrate, because this console couldn't change baudrate.")
    system("stty -F /dev/ttyS#{nTargetPort} | grep speed")
    cCom = SerialPort.new("/dev/ttyS#{nTargetPort}")
  end

  while true
    sLine = cCom.gets()
    print(sLine)
    sLogData += sLine
    if (sLine.include?("Kernel Exit..."))
      break
    end
  end

  cCom.close()
}


# COMポート接続中もctrl+cで強制終了するためのダミースレッド
thDummy = Thread.new {
  while true
    sleep(1)
  end
}

# 10分でタイムアウト
# (シリアル受信が停止した場合への対処)
result = thMain.join(600)
if (result.nil?())
  puts("[com_port.rb] timeout!!")
  cCom.close()
end

# ログファイル出力
File.open(sLogFile, "w"){|io|
  io.puts(sLogData)
}

