from audioop import add
from web3 import Web3

web3 = Web3(Web3.HTTPProvider("https://kovan.infura.io/v3/64f2b92ea98d47b8a584976f7f051d08"))
private_key = "5f22a80a0824462fc1ed3b79306696b79dd3ed5dbb9a69287f1aa2cddb4413ef"
print(web3.isConnected())

print(web3.eth.get_balance("0x4C17894120a506f1e2F34c5fE5FDAba25FF9D3e3"))
contract_address = "0xaCEB62d470D34a64c6218217207Efad891ba085B"
contract_abi = [
	{
		"inputs": [
			{
				"internalType": "uint32",
				"name": "_number_of_entities",
				"type": "uint32"
			},
			{
				"internalType": "uint32",
				"name": "_number_of_features",
				"type": "uint32"
			}
		],
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "enitity_address",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "number_of_entities",
		"outputs": [
			{
				"internalType": "uint32",
				"name": "",
				"type": "uint32"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "number_of_features",
		"outputs": [
			{
				"internalType": "uint32",
				"name": "",
				"type": "uint32"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "public_key",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "entity",
				"type": "address"
			}
		],
		"name": "submit_entity",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "pubkey",
				"type": "uint256"
			}
		],
		"name": "submit_pubkey",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256[3]",
				"name": "_mu",
				"type": "uint256[3]"
			},
			{
				"internalType": "uint256[3]",
				"name": "vars",
				"type": "uint256[3]"
			},
			{
				"internalType": "string",
				"name": "class",
				"type": "string"
			}
		],
		"name": "submit_update",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	}
]
aggregator = web3.eth.contract(address= contract_address, abi = contract_abi)
my_account = web3.eth.account.privateKeyToAccount(private_key)
print(my_account.address)
print(aggregator.functions.number_of_features().call())
chain_id = 42
print(web3.eth.getTransactionCount(my_account.address))
transaction = aggregator.functions.submit_entity("0xaCEB62d470D34a64c6218217207Efad891ba085B").buildTransaction({
    "chainId": chain_id, 
    "gas": 5000000, 
    "nonce": web3.eth.getTransactionCount(my_account.address)})
signed_tx = web3.eth.account.signTransaction(transaction, private_key)

receipt = web3.eth.waitForTransactionReceipt(web3.eth.sendRawTransaction(signed_tx.rawTransaction))
print(aggregator.functions.enitity_address(0).call())
print(receipt)
print(web3.eth.getTransactionCount(my_account.address))