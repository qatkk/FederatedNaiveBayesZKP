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