#!/usr/bin/env ruby
#####################################################################
#
#                              macro.rb
#
#                                                  (c) 2013 tyabuta.
#####################################################################

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
# tmpdir functions
# -------------------------------------------------------------------
if $".include?('tmpdir.rb') then

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
if $".include?('sqlite3.rb') then

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

