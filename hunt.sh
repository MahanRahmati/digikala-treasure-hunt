#!/usr/bin/bash

function getProducts() {
    rm 1a
    curl --parallel --parallel-immediate --parallel-max 8 -L https://www.digikala.com/treasure-hunt/products/?sortby=21 >>1a
    curl --parallel --parallel-immediate --parallel-max 8 -L "https://www.digikala.com/treasure-hunt/products/?pageno=[2-47]&sortby=21" >>1a
    cat 1a | LANG=C sed '/href=[\"]\/product\/dkp-/!d' | LANG=C sed '/div/d' | sed 's/href=/https:[\/][\/]www.digikala.com/' | LANG=C sed 's/\[//' | LANG=C sed 's/\]//' | LANG=C sed 's/\[//' | LANG=C sed 's/\]//' | LANG=C sed 's/[\"]//' | LANG=C sed 's/[\"]//' | LANG=C sed 's/^ *//g' | LANG=C sed 's/^[[:space:]]*//g' | LANG=C sed 's/0\/.*/0/' | LANG=C sed 's/1\/.*/1/' | LANG=C sed 's/2\/.*/2/' | LANG=C sed 's/3\/.*/3/' | LANG=C sed 's/4\/.*/4/' | LANG=C sed 's/5\/.*/5/' | LANG=C sed 's/6\/.*/6/' | LANG=C sed 's/7\/.*/7/' | LANG=C sed 's/8\/.*/8/' | LANG=C sed 's/9\/.*/9/' | LANG=C sed 's/.* //' >products
}

function getHTMLs() {
    declare -i x=0
    name=''
    while IFS= read -r line; do
        x=x+1
        echo '------------------------'
        echo '----------'$x'----------'
        echo '------------------------'
        name=$(echo "$line" | sed 's/https:[\/][\/]www.digikala.com[\/]product[\/]dkp-//' | sed 's/^ *//g' | sed 's/^[[:space:]]*//g')
        curl --parallel --parallel-immediate --parallel-max 8 "$line" >"$name"'.html'
        pup '#gallery-content-1' <"$name".html | cat >"$name".txt
        mv "$name".html hfiles/"$name".html
        if cmp --silent -- htmls/"$name".txt "$name".txt; then
            rm "$name".txt
        else
            rm htmls/"$name".txt
            cp "$name".txt htmls2/"$name".txt
            mv "$name".txt htmls/"$name".txt
        fi
    done <$1
}

function downloadHTMLs() {
    rm xaa
    rm xab
    rm xac
    rm xad
    rm xae
    rm xaf
    rm xag
    rm xah
    rm xai
    split -l 206 products
    getHTMLs xaa & 
    getHTMLs xab &  
    getHTMLs xac & 
    getHTMLs xad & 
    getHTMLs xae & 
    getHTMLs xaf & 
    getHTMLs xag & 
    getHTMLs xah & 
    wait
    getHTMLs xai
}

function getImages() {
    for file in htmls2/*.txt; do
        sed 's/jpg.*/jpg/' $file | sed '/src=[\"]/!d' | sed 's/<img data-src=[\"]//' | sed 's/^ *//g' | sed 's/^[[:space:]]*//g' | sed '/<div class/d' | grep -oh 'https://dkstatics-public.digikala.com/digikala-products/.*jpg' >>urls
    done
    sort -u urls >>images
    rm urls
}

function checkImages() {
    while IFS= read -r line; do
        if [[ $(cat check) == *"$line"* ]]; then
            grep -v "$line" images >filename2a
            mv filename2a images
        fi
    done <images
}

function downloadImages() {
    cat images | wget -N -P /Users/mahan/Development/Digikala/files/ -i-
}

getProducts
downloadHTMLs
getImages
checkImages
downloadImages