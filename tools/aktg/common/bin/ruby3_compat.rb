# -*- coding: utf-8 -*-
#
#  Ruby 2.x/3.x で AKTG (Ruby 1.9.3 向けに書かれている) を動かすための互換層．
#  aktg.rb の先頭で読み込む．Ruby 1.9.3 では何もしない．
#

# Ruby 2.4 で Integer に統合，3.2 で定数自体が削除された
Fixnum = Integer unless defined?(Fixnum)
Bignum = Integer unless defined?(Bignum)

# Ruby 3.2 で Object#=~ が削除された (従来は常に nil を返した)．
# AKTG は String 以外 (Integer，true 等) にも =~ を適用している．
class Object
  def =~(other)
    nil
  end unless method_defined?(:=~)
end

# File.exists?/Dir.exists? は Ruby 3.2 で削除された
class << File
  alias_method :exists?, :exist? unless method_defined?(:exists?)
end
class << Dir
  alias_method :exists?, :exist? unless method_defined?(:exists?)
end

# curses は Ruby 2.1 で標準添付から外れた．AKTG はプログレスバーの
# 幅計算に端末の桁数を得るためだけに使うので，無ければ代替する．
begin
  require "curses"
rescue LoadError
  module Curses
    def self.init_screen; end
    def self.close_screen; end
    def self.cols
      return ENV["COLUMNS"].to_i if ENV["COLUMNS"].to_i > 0
      begin
        require "io/console"
        cols = IO.console && IO.console.winsize[1]
        return cols if cols && cols > 0
      rescue StandardError, LoadError
      end
      160
    end
  end
end
