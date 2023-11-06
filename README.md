# FederatedNaiveBayesZKP

The provided code serves as the tangible realization of the proof of concept outlined in the research paper titled "Federify: A Verifiable Federated Learning Scheme based on zkSNARKs and Blockchain." This implementation not only embodies the theoretical concepts discussed in the paper but also demonstrates their practical applicability in the realm of federated learning, zkSNARKs, and blockchain technologies.

In essence, this code showcases the concrete manifestation of the innovative ideas presented in the academic work, allowing us to experiment, test, and assess the viability of the Federify scheme within a real-world context. It serves as a testament to the potential and feasibility of the proposed federated learning scheme, underpinned by the powerful combination of zero-knowledge succinct non-interactive arguments of knowledge (zkSNARKs) and blockchain technology.

By delving into this codebase, one can gain a deeper understanding of how the federated learning framework, as detailed in the research paper, can be implemented and operationalized. It provides a valuable resource for researchers, developers, and enthusiasts to explore, scrutinize, and potentially build upon, thereby advancing the field of federated learning and its integration with zkSNARKs and blockchain technology.


## Project structure

Certainly, there's a structured description of the project's components:

**Dataset:**
The dataset used for this implementation can be found at "https://mdx.figshare.com/articles/dataset/Dataset_used_for_federated_learning/14107121". This dataset is used for federated learning use cases and for health monitoring purposes. The dataset classifies the outputs of an accelerometer sensor embedded in smartphones to detect the activity status of the person carrying the smartphone. The activities are classified as Sitting, Jogging, Walking, and Running. Although this dataset has only four numeric features, the preprocessing adds abstract features to it based on the parameters specified in "configs/params.json". In this implementation, the values are solely used as a proof of concept for implementing and applying the scheme structure.

**Codes:**  
This directory contains Python and JavaScript files that are responsible for various aspects of the project, including model training, smart contract interaction, and decryption processes.
- `initialize_encryption.js`: Creates the encryption keys for the number of entities (MOs) for the specified number of entities in the configs folder. 
- `data_add.py` and `data_categ.py` and `preprocessing.py`: These are Python files for preprocessing tha data corresponding to the scheme's needs.
- `class_learn.py`: Trains the data for a specified batch size and class. 
- `partial_decrypt.js`:  JavaScript file related to the partial decryption process. This code retrieves the parameters from the smart contract and decrypts them with the set decryptor ID when running the node. 
- `decrypt.js`: This file uses the final decrypted version of the Mean model parameters from the smart contract and returns the Mean values (decrypted values) as a results. In the end, you can see wheter the decrypted values are the same as the summation of all the mean parameters submitted when running the `test\mode_test.sh`. 
- `encrypt.js ` and `encrypt_model.js`: These are the Javascript file to conduct the encryption on the trained model parameters. 
-  `sc_submit_model.js`, `sc_start_decryption.js`, `sc_submit_decryption.js`, and `sc_submit_public_key.js` : Are files for interacting with the smart contract at the address specified in the "configs/params.json" file after deployment of the contract. 

**Contracts:**  
This directory houses the Ethereum smart contracts used in the project, each serving a specific purpose.

- `BJJ.sol`: Smart contract containing curve parameters for the encryption mathematics.
- `FLSC.sol`: Main smart contract responsible for managing federated learning operations.
- `MVSC.sol`: Verifier smart contract for model verification.
- `DVSC.sol`: Verifier smart contract for decryption verification.
- `verifier.sol`: The verifier contract deployed to the blockchain alongside FLSC contract to prove the decryption and model update process. 

**Zokrates:**  
The Zokrates directory contains zkSNARK circuits and libraries used in the project.

- `Decryption`: Subdirectory containing zkSNARK circuits related to partial decryption for Model Owners (MOs).
- `Model_verif`: Subdirectory containing zkSNARK circuits related to model verification for Data Owners (DOs).

This structured organization of the project's components facilitates clarity and ease of navigation, making it straightforward for developers and collaborators to understand and work with the various aspects of the project, including cryptography, smart contracts, and model training.

## Project dependencies:

- Install npm:

```sudo apt-get install npm```

At least version 18 is needed. To upgrade (if needed), execute:

```
npm cache clean -f
npm install n
n stable
```

- Install NodeJS dependencies. In order to install NodeJS dependencies after cloning the repository please run "npm install --force --loglevel=error".

```
npm install --force --loglevel=error
```

- Install the ZoKrates toolset. You can find more information about this project at the link https://zokrates.github.io/. In order to be able to run ZoKrates codes in this repository please install the [7.14 version of ZoKrates](https://github.com/Zokrates/ZoKrates/releases/tag/0.7.14).

```
wget https://github.com/Zokrates/ZoKrates/releases/download/0.7.14/zokrates-0.7.14-x86_64-unknown-linux-gnu.tar.gz
mkdir ~/.zokrates
tar -xzf zokrates-0.7.14-x86_64-unknown-linux-gnu.tar.gz --directory ~/.zokrates
export PATH=$PATH:~/.zokrates
```

Alternatively, a docker image of the 7.14 version of ZoKrates can be obtained with: 

```
docker pull zokrates/zokrates:0.7.14
```

* Install python and pip:

```
apt-get install python3 python3-pip
```

* Install python dependencies:

```
pip3 install -r requirements.txt
```


## Running instructions

**Blockchain interaction:** 
In this tests, multiple files interact with the Goerli testnet to send and recieve data. For this cause a Metamask wallet is used. If when running tests you ran into "error: Insufficient funds", the wallet has ran out of Ethers to send transactions to the blockchain. 
Please use the Goerli faucet at the address "https://goerli-faucet.pk910.de/" and send funds to the test wallet at address "0x4C17894120a506f1e2F34c5fE5FDAba25FF9D3e3" to be able to run the tests. 

**Scheme setup:** 
- Inorder to generate the verifier smart contracts for computation verification you need to first setup the zkSNARK circuits provided in "zokrates/" folder. For this cause you have to set the number of features and batchsize corresponding to your dataset in `configs/params.json`. As you can see in this file you set the batch size, number of the features of the dataset, number of the model owners, and the class that you want to train and sumti a model for.
- Run `setup/setup.# FederatedNaiveBayesZKP
```
cd setup
./setup.sh
```

**Model owner registration:**
- Since in this case we are just testing the scheme feasibility, the model owner registration is not done for each of the model owners and instead the total public key- the added values for all the public keys of the model owners- is submitted to the contract. To do so, before submitting any model updates, you have to run `test/submit_pk.sh` to send a transaction to the smart contract with the scheme's public key.

```
cd ../test
./submit_pk.sh
```

**Model training:**
- In order to test the model update process and training you can run the `test/model_test.sh` file. This file will train the model and create a proof corresponding to the trained class. When the model update is verified locally then this file will send a transaction to the submit_model_update() function of the FLSC to update the global model. You can choose the number of model updates sent to the smart contract at the first of the scripts, this way the script will train and submit multiple model updates for the same class of data specified in the `configs/params.json` file.

```
./model_test.sh
```


**Decryption process:**
- In order to test the model update process and training you can run the `test/decrypt_test.sh` file. This file will obtain the global model and create a proof corresponding to the partial decryption. When the decryption is verified locally this file will send a transaction to the submit_decryption() function of the FLSC to update the partially decrypted model.

```
./decrypt_test.sh
```