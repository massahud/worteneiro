#!/bin/bash
regex='({"@context":"http:\/\/schema.org\/","@type":"Product"([^<]*)})<\/script>'
echo "-----------------------------------------------------"
while IFS=$',' read url preco ; do
    curl -s "$url" -o produto.html 
    if [[ $(<produto.html) =~ $regex ]]; then
        produto=$(jq -r '.name' <<< "${BASH_REMATCH[1]}")
        precoAtual=$(jq -r '.offers.price' <<< "${BASH_REMATCH[1]}")
        if [[ $(bc <<< "$preco > $precoAtual") = "1" ]]; then
            echo "${produto} (${precoAtual}) está abaixo de ${preco}! COMPRE AGORA!"
            echo "URL: ${url}"
            echo "-----------------------------------------------------"
        else
            echo "${produto} (${precoAtual}) está acima de ${preco}! NÃO COMPRE!"
            echo "URL: ${url}"
            echo "-----------------------------------------------------"
        fi
    else
        echo "DADOS DO PRODUTO NÃO ENCONTRADOS! ${url}"
    fi
    rm produto.html
done < "produtos.csv"
