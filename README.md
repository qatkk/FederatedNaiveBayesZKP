# FederatedNaiveBayesZKP

The provided code serves as the tangible realization of the proof of concept outlined in the research paper titled "Federify: A Verifiable Federated Learning Scheme based on zkSNARKs and Blockchain." This implementation not only embodies the theoretical concepts discussed in the paper but also demonstrates their practical applicability in the realm of federated learning, zkSNARKs, and blockchain technologies.

In essence, this code showcases the concrete manifestation of the innovative ideas presented in the academic work, allowing us to experiment, test, and assess the viability of the Federify scheme within a real-world context. It serves as a testament to the potential and feasibility of the proposed federated learning scheme, underpinned by the powerful combination of zero-knowledge succinct non-interactive arguments of knowledge (zkSNARKs) and blockchain technology.

By delving into this codebase, one can gain a deeper understanding of how the federated learning framework, as detailed in the research paper, can be implemented and operationalized. It provides a valuable resource for researchers, developers, and enthusiasts to explore, scrutinize, and potentially build upon, thereby advancing the field of federated learning and its integration with zkSNARKs and blockchain technology.

Certainly, here's a structured description of the project's components:

**Codes:**  
This directory contains Python and JavaScript files that are responsible for various aspects of the project, including model training, smart contract interaction, and decryption processes.
- `initialize_encryption.js` and `pubkey_gen.js` : Creates the encryption keys for the number of entities (MOs) for the specified number of entities in the configs folder. 
- `data_add.py` and `data_categ.py` and `preprocessing.py`: Are Python files for preprocessing tha data corresponding to the scheme's needs.
- `class_learn.py` : Trains the data for a specified batch size and class. 
- `decryption.py` and `decryption.js`: Python and JavaScript files related to the decryption process.
- `encrypt.js ` and `encrypt_model.js`: Are the Javascript file to conduct the enryption on the trained model parameters. 
-  `sc_submit_model.js` and `sc_start_decryption.js` and `sc_submit_public_key.js` and `sc_verification_status.js`: Are files for interacting with the smart contract ad the address specified in the "configs/contract_addr.txt" file. 

**Smart Contracts:**  
This directory houses the Ethereum smart contracts used in the project, each serving a specific purpose.

- `Bijj.sol`: Smart contract containing curve parameters for the encryption mathematics.
- `FLSC.sol`: Main smart contract responsible for managing federated learning operations.
- `MVSC.sol`: Verifier smart contract for model verification.
- `DVSC.sol`: Verifier smart contract for decryption verification.
- `Verifier_template.sol`: A template used to create verifier smart contracts, which are meant to be deployed alongside the main smart contract for specific verification tasks.

**Zokrates:**  
The Zokrates directory contains zkSNARK circuits and libraries used in the project.

- `Decryption`: Subdirectory containing zkSNARK circuits related to partial decryption for Model Owners (MOs).
- `Model_verif`: Subdirectory containing zkSNARK circuits related to model verification for Data Owners (DOs).

This structured organization of the project's components facilitates clarity and ease of navigation, making it straightforward for developers and collaborators to understand and work with the various aspects of the project, including cryptography, smart contracts, and model training.

** Project setup: ** 

- `NodeJS dependencies`: In order to install nodejs dependencies after cloning the repository please run "npm install".
- `zkSNARK`: In this project we use the ZoKrates toolset. You can find more information about this project at link https://zokrates.github.io/. In order to be able to run ZoKrates codes in this repository please install the 7.14 version of ZoKrates. https://github.com/Zokrates/ZoKrates/releases/tag/0.7.14

** Scheme setup: ** 
- Inorder to generate the verifier smart contracts for computation verification you need to first setup the zkSNARK circuits provided in "zokrates/" folder. For this cause you have to set the number of features corresponding to your dataset in the main.zok files found in "zokrates/decryption" and "zokrates/model_verif". 
- Run setup.sh 
- Copy the content of "smart_contracts/DVSC.sol" and "smart_contracts/MVSC.sol" to "smart_contracts/verifier.sol"as defined "verifier.sol"
- Change the "input" variable size corresponding to the inputs of verifyTx in each contract in the functions submit_Decryption and submit_model_update in FLSC.sol 
- Deploy "FLSC.sol" with the "BJJ.sol" and "verifier.sol" in the Remix IDE. 
- Copy the address of the deployed FLSC in the "codes/configs/contract_addr.txt"
- Set the number of features in the "codes/configs/number_of_features.txt"
- Set the number of model owners in the "codes/configs/number_of_entities.txt"
- Run "codes/submit_pk.sh" in order to submit the public key needed for encryption of the model updates. 

** Model training: ** 
- In order to test the model update process and training you can run the "codes/model_test.sh" file. This file will train the model and create a proof corresponding to the trained class. When the model update is verified locally then this file will send a transaction to the submit_model_update() function of the FLSC to update the global model. 


** Decryption process: ** 
- In order to test the model update process and training you can run the "codes/decrypt_test.sh" file. This file will obtain the global model and create a proof corresponding to the partial decryption. When the decryption is verified locally then this file will send a transaction to the submit_decryption() function of the FLSC to update the partially decrypted model. 