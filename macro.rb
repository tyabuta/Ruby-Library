#!/usr/bin/env ruby
#####################################################################
#
#                              macro.rb
#
#                                                  (c) 2013 tyabuta.
#####################################################################




#
# 配列をインデックス付きで出力する。
# base: 出力するインデックスのベース(省略時はゼロ)
#
def ArrayListOutputWithIndex(arr, base=0)
    arr.each_with_index { |a, i| puts "#{i+base}) #{a}" }
end

#
# 配列のインデックスが、範囲ないかしらべる。
#
def ArrayIndexInRange(arr, i)
    return (0 <= i && i < arr.count)
end

#
# 選択肢出力用の関数
# 選択された項目のインデックスを返します。
# Cancelが選択された場合 -1
#
def PromptSelectMenuWithArray(arr, msg)
    puts msg
    puts "0) cancel"
    arr.each_with_index { |a, i| puts "#{i+1}) #{a}" }
    
    print ">> "
    return gets.to_i() -1
end


#
# 指定のモジュールが含まれているか調べる。
#
def module_include?(module_name)
    return $".include?(module_name + '.rb')
end


#
# 複数の連続するスペース、タブなどを一つのスペースに置換する。
# 改行文字もスペースとなる。 
#
def StringSingleSpaceReplaceWithMulti(str)
    return str.gsub(/\s+/, " ")
end

#
# 定数ARGVから、値を取得する。
#
#         i: 引数の番号(0ベース)
# def_value: 値がなかった場合のデフォルト値
#
def paramWithArgumentNumber(i, def_value="")
    return ARGV[i] || def_value
end

#
# 起動したスクリプト自身のディレクトリPathを取得する。
#
def FSScriptBinDir()
    return File.expand_path(File.dirname($0))
end

#
# 実行したスクリプトディレクトリから相対的なPathを返す。
#
def FSScriptBinRelativePath(relative_path)
    path = File.join(File.dirname($0), relative_path)
    return File.expand_path(path)
end


#
# 正規表現にマッチした行をきっかけに、次の行からファイル読み込みを開始する。
#
# file_object: ファイルオブジェクト
# regex_begin: 読み込みのきっかけとなる正規表現
#   regex_end: 読み込み終了の合図となる正規表現、
#              省略した場合はファイルの最後まで読み込みを行う。
#
def ReadBeginWithLine(file_object, regex_begin, regex_end=nil)
    buf = ""
    while file_object.gets
        if $_ =~ regex_begin then
            while file_object.gets
                if regex_end then
                    break if $_ =~ regex_end
                end
                buf += $_
            end
        end
    end
    return buf
end


#
# 指定のディレクトリがGitリポジトリならtrueを返す。
#
def DirectoryIsGitRepository(dir)
    return true if FileTest.directory?(dir) && 
                   FileTest.directory?(File.join(dir, ".git"))               
    return false
end 


# 
# 指定PATHの末尾に拡張子を付加する。
# path: 既に指定の拡張子が付いている場合は何もしない。
#  ext: .(ドット)は付けても付けなくても自動で解釈されます。
#
def PathAppendExtension(path, ext)
    # 拡張子にドットがない場合、付ける。
    ext = "."+ext unless "."==ext[0,1]
    # 拡張子を付加する。
    return path+ext unless path =~ /#{ext}$/i
    return path
end


#
# 標準入力から文字列を取得する
#
def StdInString(msg)
    print msg
    return gets.chomp
end


#
# y/n の確認を求め、無効な値の場合は繰り返します。
# y -> true  n -> false
#
def PromptConfirm(msg)
    while 1
        print msg + " [yes/no] >>> "
        res = gets.chomp.downcase
        if   "y"==res || "yes"==res then
            return true
        elsif "n"==res || "no"==res then
            return false
        end
    end
end


#
# DVDラベルのISO9660規格にあったラベル文字列か調べる。
#
# DVDラベルとはISO9660フィールドというDVD再生時に表示される標題。
# 使える文字は半角英大文字と数字、あと「_」（半角アンダースコア）で、
# ３２文字以内で表記する事と決まっている。
# 英小文字や半角スペースは禁止文字です。
#
def MediaDVDLabelIsISO9660(label)
    return true if label =~ /^[A-Z0-9_]{1,32}$/
    return false
end


# -------------------------------------------------------------------
# DateTime functions
# -------------------------------------------------------------------

if module_include? 'date' then

#
# DateTimeオブジェクトを文字列に変換する。
# 出力例) 2013/05/05 17:18:03 +09:00
#
def StringDateTimeFormat(datetime)
    return datetime.strftime("%Y/%m/%d %H:%M:%S %Z").to_s
end

#
# 下記書式にマッチした文字列から、DateTimeオブジェクトを作成する。
# 書式が違い、パースに失敗した場合はnilをかえす。
# 書式例) 2013/05/05 17:18:03 +09:00
#
def DateTimeMakeWithString(str_datetime)
    begin
        return DateTime.strptime(str_datetime, "%Y/%m/%d %H:%M:%S %Z")
    rescue
        return nil
    end
end

end # include date

# -------------------------------------------------------------------
# tmpdir functions
# -------------------------------------------------------------------
if module_include? 'tmpdir' then

#
#  一時ディレクトリを作成し、ブロック構文により
#  そのディレクトリで作業する事ができる。
#  ブロック構文を抜けると、元のカレントディレクトリに移動し、
#  一時ディレクトリは全て削除されます。
#
# tmpwork { |tmp_dir| something }
#
def tmpwork
    current_dir = Dir.pwd
    Dir.mktmpdir { |tmp_dir|
        Dir.chdir tmp_dir 
        yield tmp_dir
        Dir.chdir current_dir
    }
end

end # include tmpdir

# -------------------------------------------------------------------
# SQLite3 functions
# -------------------------------------------------------------------
if module_include? 'sqlite3' then

#
# SQLite3接続
# 失敗時はnilを返す。　
#
def DBConnect(dbname)
    begin
        return SQLite3::Database.new(dbname)
    rescue
    end
    return nil
end 

#
# DB接続を閉じる。
#
def DBDisconnect(db)
    db.clone if (nil != db)
end

#
# SQL実行を行う。
# SQL実行に成功した場合true
#
def DBExecute(db, sql, *args)
    begin
        db.execute sql, *args
    rescue
        return false
    end
    return true
end

#
# レコードが存在する場合true
#
def DBExists(db, sql, *args)
    db.execute(sql, *args) {
        return true
    }
    return false
end

end # include sqlite3



# -------------------------------------------------------------------
# logger functions
# -------------------------------------------------------------------
if module_include? 'logger' then

#
# Logの出力関数
# ログに改行が含まれる場合は'\n'として出力されます。
# グローバル変数 $_logger を使用します。
#
# logname: 関数初回呼び出し時にログPathを指定します。
#          *省略時は"script.log"というファイル名になります。
#          *関数呼び出し２回目以降は無視されます。
#
def log(msg, logname="script.log")
    # 初回でインスタンス作成
    $_logger = Logger.new(logname) if nil==$_logger
    # 改行は\nとして記録する。
    $_logger.info(msg.gsub("\n", '\n'))
end

end # include logger




# -------------------------------------------------------------------
# git functions
# -------------------------------------------------------------------

#
# カレントブランチを取得する。
# 取得に失敗した場合は空文字列を返す。
#
def GitBranchGetCurrent()
    git_status = `git status 2>&1`
    if git_status =~ /# On branch (.+)$/ then
        current_branch = $1
        return current_branch
    end
    return ""
end



