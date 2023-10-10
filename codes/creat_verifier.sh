sed "s/contract Verifier.*/contract MVSC{/"  ../smart_contracts/MVSC.sol > ../smart_contracts/verifier.sol
sed '1,145d' ../smart_contracts/DVSC.sol > ../smart_contracts/temp_sc.sol
sed "s/contract Verifier.*/contract DVSC{/"  ../smart_contracts/temp_sc.sol >> ../smart_contracts/verifier.sol
rm ../smart_contracts/temp_sc.sol