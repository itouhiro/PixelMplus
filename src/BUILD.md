PixelMplus : How to Build
=========================

Copyright (C) 2013 itouhiro  
Copyright (C) 2002-2013 M+ FONTS PROJECT


Build
-----

```
$  sh build_PixelMplus10.sh
$  sh build_PixelMplus12.sh
$  fontforge -script PixelMplus10-Regular.pe
$  fontforge -script PixelMplus10-Bold.pe
$  fontforge -script PixelMplus12-Regular.pe
$  fontforge -script PixelMplus12-Bold.pe
```

生成スクリプトは
http://sourceforge.jp/cvs/view/mplus-fonts/mplus_outline_fonts/
から取得しました。

詳しくは以下を参照。  
http://itouhiro.hatenablog.com/entry/20130602/font


Build Requirements
------------------

* ビットマップフォント（BDF）編集
    * Windows 7
    * [bmp2bdf](http://hp.vector.co.jp/authors/VA013241/font/bmp2bdf.html)
    * [bdf2bmp](http://hp.vector.co.jp/authors/VA013241/font/bdf2bmp.html)
    * Adobe Photoshop

* アウトラインフォント生成
    * Debian Linux 6
    * fontforge 0.0.20100501-5
    * perl 5.10.1-17squeeze4


Reference
---------

JIS X 0213⇔Unicodeの文字コード変換表として、
以下を配布物に含めました。 ucstable.d/JISX0213.TXT です。

- JIS X 0213:2004 漢字8ビット符号とUnicodeの対応表  
  http://x0213.org/codetable/jisx0213-2004-8bit-std.txt



License
-------

M+ FONT LICENSE

M+ FONT LICENSEについては、配布物に含まれる
[mplus_bitmap_fonts/LICENSE_E](../misc/mplus_bitmap_fonts/LICENSE_E)
をご覧ください。
