function pdfview
  set tmp (mktemp -d)
  pdftoppm -png -r 150 $argv[1] $tmp/page
  kitten icat $tmp/page-*.png
  rm -rf $tmp
end
