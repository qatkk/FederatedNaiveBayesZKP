#!/bin/bash


beta=$(node -pe 'JSON.parse(process.argv[1]).batch_size' $(< ../configs/params.json))
feature=$(node -pe 'JSON.parse(process.argv[1]).number_of_features' $(< ../configs/params.json))

sed "s/number_of_features/$feature/g" ../zokrates/decryption/main_template.zok > ../zokrates/decryption/main.zok


sed "s/number_of_features/$feature/g" ../zokrates/model_verif/main_template.zok > ../zokrates/model_verif/temp.txt
sed "s/batch_size/$beta/g" ../zokrates/model_verif/temp.txt > ../zokrates/model_verif/main.zok


rm ../zokrates/model_verif/temp.txt 