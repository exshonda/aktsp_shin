
require 'csv'
require 'fileutils'

require 'aktb_log.rb'

class MnfGenerator

  #=====================================================================
  # 各実行バイナリのパス
  #=====================================================================
  CMD_FIND = "/usr/bin/find"
  CMD_SORT = "/usr/bin/sort"

  #=====================================================================
  # 初期化関数
  #=====================================================================
  def initialize(cfg_obj, cmy_tesrys)

    # 設定オブジェクト(ハッシュ)
    @config     = cfg_obj
    
    # TESRYのあるディレクトリ
    @cmy_tesry_dirs  = cmy_tesrys

    # ディレクトリパス初期化
    @aktsp_dir       = `pwd`.chomp + "/../"
    @root_dir        = @aktsp_dir + @config["obj_root_path"]
    @tesry_dir       = @aktsp_dir + @config["obj_tesry_path"]

    # 強制マージ有効/無効
    @use_force_merge = @config["use_force_merge"]

    # 強制マージ分割設定
    if @use_force_merge
      @use_divide_force_merge = @config["use_divide_force_merge"]
      if @use_divide_force_merge
        @divide_force_merge_config_file = @aktsp_dir + @config["divide_force_merge_config_file"]
      end
    end

    # AUTO_CODE有効/無効
    @use_auto_code   = @config["use_auto_code"]

    # AUTO_CODE使用時分割数
    @divide_num      = @config["divide_num"]

    # スケーラビリティクラス
    @scalability_class = @config["scalability_class"]

    # インスタンス変数初期化
    @new_manifests   = []
  end

  #=====================================================================
  # マニフェストファイルを生成し、ビルド単位で分割
  #=====================================================================
  def execute
    AktbLog.instance.info("[generate_manifest_files] START")

    # [強制マージ]マニフェスト処理
    if @use_force_merge

      # マニフェスト生成
      generate_manifest_fm

      # 強制マージ分割(有効にしている場合のみ)
      if @use_divide_force_merge
        divide_manifest_fm
      end

    # [非強制マージ]マニフェスト処理
    else

      # マニフェスト生成
      generate_manifest

      # AUTO_CODE使用(マージ時)の場合のマニフェスト分割
      if @use_auto_code
        divide_merge_manifest

      # AUTO_CODE非使用(非マージ時)の場合のマニフェスト分割
      else
        divide_not_merge_manifest
      end
    end

    AktbLog.instance.info("[generate_manifest_files] FINISH")
    @new_manifests
  end

  #=====================================================================
  # [強制マージ] yamlごとにマニフェストファイルを生成
  #=====================================================================
  def generate_manifest_fm
    AktbLog.instance.info("[generate_manifest_fm] START")
    FileUtils.mkdir_p(@root_dir)
    @cmy_tesry_dirs.each{ |cmy_tesry_dir|
      cmy_basename = File.basename(cmy_tesry_dir)
      new_manifest = @root_dir + "/" + "MNF_" + cmy_basename
      @new_manifests << new_manifest
      pid  = -1
      pid2 = -1
      IO.pipe{|r, w|
        pid  = spawn("#{CMD_FIND} #{@tesry_dir}/#{cmy_basename} -name \"*yaml\"", :out=>w)
        pid2 = spawn("#{CMD_SORT}" , :in=>r, :out=>[new_manifest, "a"])
      }
      thr  = Process.wait(pid)
      thr2 = Process.wait(pid2)
    }
    AktbLog.instance.info("[generate_manifest_fm] FINISH")
  end

  #=====================================================================
  # [強制マージ] マニフェストファイルを分割
  #=====================================================================
  def divide_manifest_fm
    AktbLog.instance.info("[divide_manifest_fm] START")

    # csvファイル読み込み→ハッシュに格納
    divnum_hash = {}
    CSV.table(@divide_force_merge_config_file, headers:false).each{|cmy, num|
      if cmy =~ /#{@scalability_class}/
        cmy.slice!(/^.*:/)
        cmy.slice!(/\.cmy$/)
        if divnum_hash.has_key?(cmy) 
          AktbLog.instance.warn("Duplicate cmy information(OVERWRITE by LATTER): #{cmy}")
        end
        divnum_hash[cmy] = num
      end
    }
    # マニフェストファイルの分割
    replace_manifests =[]
    @new_manifests.each{|manifest|
      mnf_key = File.basename(manifest)
      mnf_key.slice!("MNF_")
      if divnum_hash.has_key?(mnf_key)
        divide_num = divnum_hash[mnf_key]
      else
        replace_manifests << manifest
        next
      end

      array_tesry = []
      (1..divide_num).each{|counter|
        array_tesry[counter] = []
      }
      div_counter = 1
      File.read(manifest).split("\n").each{|yaml_line|
        array_tesry[div_counter].push(yaml_line)
        div_counter += 1
        if (div_counter > divide_num)
          div_counter = 1
        end
      }

      (1..divide_num).each{|counter|
        new_manifest = manifest +  "_" + counter.to_s
        replace_manifests << new_manifest
        File.write(new_manifest, array_tesry[counter].join("\n"))
      }
      FileUtils.remove(manifest)
    }

    # マニフェストファイルのリストを置き換え
    @new_manifests = replace_manifests
    AktbLog.instance.info("[divide_manifest_fm] FINISH")
  end

  #=====================================================================
  # [マージ/非マージ] マニフェストファイルを作成
  #=====================================================================
  def generate_manifest
    AktbLog.instance.info("[generate_manifest] START")
    FileUtils.mkdir_p(@root_dir)
    pid  = -1
    pid2 = -1
    IO.pipe{|r, w|
      pid  = spawn("#{CMD_FIND} #{@tesry_dir} -name \"*yaml\"", :out=>w)
      pid2 = spawn("#{CMD_SORT}" , :in=>r, :out=>["#{@root_dir}/MANIFEST", "a"])
    }
    thr  = Process.wait(pid)
    thr2 = Process.wait(pid2)
    AktbLog.instance.info("[generate_manifest] FINISH")
  end

  #=====================================================================
  # [マージ] 分割数に応じて、マニフェストを複数のマニフェストに分割
  #=====================================================================
  def divide_merge_manifest()
    AktbLog.instance.info("[divide_merge_manifest] START")
    aTesry = []
    (1..@divide_num).each{|nCnt|
      aTesry[nCnt] = []
    }
    nCnt = 1
    aData = File.read("#{@root_dir}/MANIFEST").split("\n").each{|sLine|
      aTesry[nCnt].push(sLine)
      nCnt += 1
      if (nCnt > @divide_num)
        nCnt = 1
      end
    }

    (1..@divide_num).each{|nCnt|
      new_manifest = @root_dir + "/" + "MNF_auto_code" +  "_" + nCnt.to_s
      @new_manifests << new_manifest
      File.write(new_manifest, aTesry[nCnt].join("\n"))
    }
    FileUtils.remove("#{@root_dir}/MANIFEST")
    AktbLog.instance.info("[divide_merge_manifest] FINISH")
  end

  #=====================================================================
  # [非マージ] 各YAMLファイルに対して、マニフェストを分割
  #=====================================================================
  def divide_not_merge_manifest()
    AktbLog.instance.info("[divide_not_merge_manifest] START")
    File.open("#{@root_dir}/MANIFEST"){|file|
      while line = file.gets
        line.chomp!
        test_name = File.basename(line)
        if test_name.nil?
          next
        end
        test_name.gsub!(/\.yaml/, "")
        new_manifest = "#{@root_dir}/MNF_#{test_name}"
        @new_manifests << new_manifest
        File.open(new_manifest, "w"){|new_manifest|
          new_manifest.puts(line)
        }
      end
    }
    FileUtils.remove("#{@root_dir}/MANIFEST")
    AktbLog.instance.info("[divide_not_merge_manifest] FINISH")
  end

end
