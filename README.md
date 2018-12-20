# cc-extract-anchors
Extract URL's from Common Crawl data using flex scanner generator

### Compiling
```sh
$ flex scan.lex
$ cc -O2 lex.yy.c -o ccea
```

### Getting test Common Crawl data

Small test dataset:
```sh
$ wget -c http://s3.amazonaws.com/aws-publicdatasets/common-crawl/crawl-data/CC-MAIN-2013-20/segments/1368711605892/wet/CC-MAIN-20130516134005-00099-ip-10-60-113-184.ec2.internal.warc.wet.gz
```

Bigger and more recent dataset:
```sh
$ wget -c http://s3.amazonaws.com/aws-publicdatasets/common-crawl/crawl-data/CC-MAIN-2016-07/segments/1454701145519.33/warc/CC-MAIN-20160205193905-00000-ip-10-236-182-209.ec2.internal.warc.gz
```

### Extracting anchors

Unzip data file
```sh
$ gunzip CC-MAIN-20130516134005-00099-ip-10-60-113-184.ec2.internal.warc.wet.gz
```

Run scanner:
```sh
$ ./ccea < CC-MAIN-20130516134005-00099-ip-10-60-113-184.ec2.internal.warc.wet.gz > log.txt
```

You will get anchors in form
```text
source url:      http://archinect.com/feed/1/news/tag/107004/thesis
destination url: http://archinect.com/news/article/43126496/white-studio-400-book-show-installation
text: click here
====================
source url:      http://archiveofourown.org/works/410303/chapters/680617
destination url: http://archiveofourown.org/works/410303
text: <strong>There's A Strange Exhilaration</strong>
====================
source url:      http://archiveofourown.org/works/410303/chapters/680617
destination url: http://archiveofourown.org/users/InsomniaAndTea
text: <strong>InsomniaAndTea</strong>
====================
source url:      http://archiveofourown.org/works/410303/chapters/680617
destination url: http://archiveofourown.org/tags/Problem%20Sleuth%20(Webcomic)
text: Problem Sleuth (Webcomic)
```

Note that anchor text (between opening and closing &lt;a&gt; tags) may be weird sometimes
