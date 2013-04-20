#!/usr/bin/env ruby
#####################################################################
#
#                              macro.rb
#
#                                                  (c) 2013 tyabuta.
#####################################################################


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


