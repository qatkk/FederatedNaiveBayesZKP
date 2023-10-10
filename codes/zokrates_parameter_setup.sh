#!/bin/bash


beta=$(< configs/batch_size.txt)
feature=$(< configs/number_of_features.txt)

sed "s/number_of_features/$feature/g" ../zokrates/decryption/main_template.zok > ../zokrates/decryption/main.zok


sed "s/number_of_features/$feature/g" ../zokrates/model_verif/main_template.zok > ../zokrates/model_verif/temp.txt
sed "s/batch_size/$beta/g" ../zokrates/model_verif/temp.txt > ../zokrates/model_verif/main.zok


rm ../zokrates/model_verif/temp.txt 