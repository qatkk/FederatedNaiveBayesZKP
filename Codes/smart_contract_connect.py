import ethers as ethers 
import web3 as web3 
from web3.auto.infura.kovan import w3 



connected = w3.isConnected()
print(connected)
# const provider = new ethers.providers.InfuraProvider("kovan", "0090b71f3cbd4212bb37f81b9c3aeaab");
# const contractAddr = "0x97b0A631e8a49Cf7Cc4B3503BB81B5C2cEd1e1f2";
# const contractABI =[
# 	{
# 		"inputs": [
# 			{
# 				"internalType": "uint256",
# 				"name": "RegistrationTime",
# 				"type": "uint256"
# 			},
# 			{
# 				"internalType": "uint256",
# 				"name": "BiddingTime",
# 				"type": "uint256"
# 			},
# 			{
# 				"internalType": "uint256",
# 				"name": "_MinimumDeposit",
# 				"type": "uint256"
# 			}
# 		],
# 		"stateMutability": "nonpayable",
# 		"type": "constructor"
# 	},
# 	{
# 		"inputs": [
# 			{
# 				"internalType": "uint256[2]",
# 				"name": "_R",
# 				"type": "uint256[2]"
# 			},
# 			{
# 				"internalType": "uint256[2]",
# 				"name": "_C",
# 				"type": "uint256[2]"
# 			}
# 		],
# 		"name": "Bid",
# 		"outputs": [],
# 		"stateMutability": "payable",
# 		"type": "function"
# 	},
# 	{
# 		"inputs": [],
# 		"name": "BiddersSekKey",
# 		"outputs": [
# 			{
# 				"internalType": "uint256",
# 				"name": "",
# 				"type": "uint256"
# 			}
# 		],
# 		"stateMutability": "view",
# 		"type": "function"
# 	},
# 	{
# 		"inputs": [
# 			{
# 				"internalType": "uint256",
# 				"name": "",
# 				"type": "uint256"
# 			},
# 			{
# 				"internalType": "uint256",
# 				"name": "",
# 				"type": "uint256"
# 			}
# 		],
# 		"name": "Bids",
# 		"outputs": [
# 			{
# 				"internalType": "uint256",
# 				"name": "",
# 				"type": "uint256"
# 			}
# 		],
# 		"stateMutability": "view",
# 		"type": "function"
# 	},
# 	{
# 		"inputs": [],
# 		"name": "EndAuction",
# 		"outputs": [],
# 		"stateMutability": "nonpayable",
# 		"type": "function"
# 	},
# 	{
# 		"inputs": [],
# 		"name": "MinimumDeposit",
# 		"outputs": [
# 			{
# 				"internalType": "uint256",
# 				"name": "",
# 				"type": "uint256"
# 			}
# 		],
# 		"stateMutability": "view",
# 		"type": "function"
# 	},
# 	{
# 		"inputs": [],
# 		"name": "NumberOfBidders",
# 		"outputs": [
# 			{
# 				"internalType": "uint256",
# 				"name": "",
# 				"type": "uint256"
# 			}
# 		],
# 		"stateMutability": "view",
# 		"type": "function"
# 	},
# 	{
# 		"inputs": [],
# 		"name": "Owner",
# 		"outputs": [
# 			{
# 				"internalType": "address",
# 				"name": "",
# 				"type": "address"
# 			}
# 		],
# 		"stateMutability": "view",
# 		"type": "function"
# 	},
# 	{
# 		"inputs": [
# 			{
# 				"internalType": "uint256",
# 				"name": "",
# 				"type": "uint256"
# 			}
# 		],
# 		"name": "Pk",
# 		"outputs": [
# 			{
# 				"internalType": "uint256",
# 				"name": "",
# 				"type": "uint256"
# 			}
# 		],
# 		"stateMutability": "view",
# 		"type": "function"
# 	},
# 	{
# 		"inputs": [
# 			{
# 				"internalType": "uint256",
# 				"name": "",
# 				"type": "uint256"
# 			},
# 			{
# 				"internalType": "uint256",
# 				"name": "",
# 				"type": "uint256"
# 			}
# 		],
# 		"name": "Randoms",
# 		"outputs": [
# 			{
# 				"internalType": "uint256",
# 				"name": "",
# 				"type": "uint256"
# 			}
# 		],
# 		"stateMutability": "view",
# 		"type": "function"
# 	},
# 	{
# 		"inputs": [
# 			{
# 				"internalType": "uint256",
# 				"name": "_pk",
# 				"type": "uint256"
# 			},
# 			{
# 				"internalType": "uint256",
# 				"name": "r",
# 				"type": "uint256"
# 			},
# 			{
# 				"internalType": "uint256",
# 				"name": "s",
# 				"type": "uint256"
# 			},
# 			{
# 				"internalType": "uint256",
# 				"name": "m",
# 				"type": "uint256"
# 			}
# 		],
# 		"name": "RegisterBidder",
# 		"outputs": [],
# 		"stateMutability": "nonpayable",
# 		"type": "function"
# 	},
# 	{
# 		"inputs": [
# 			{
# 				"internalType": "uint256",
# 				"name": "_pk",
# 				"type": "uint256"
# 			}
# 		],
# 		"name": "RegisterServer",
# 		"outputs": [],
# 		"stateMutability": "nonpayable",
# 		"type": "function"
# 	},
# 	{
# 		"inputs": [],
# 		"name": "ReturnBidders",
# 		"outputs": [
# 			{
# 				"internalType": "address[]",
# 				"name": "",
# 				"type": "address[]"
# 			}
# 		],
# 		"stateMutability": "view",
# 		"type": "function"
# 	},
# 	{
# 		"inputs": [],
# 		"name": "ReturnBids",
# 		"outputs": [
# 			{
# 				"internalType": "uint256[][]",
# 				"name": "",
# 				"type": "uint256[][]"
# 			}
# 		],
# 		"stateMutability": "view",
# 		"type": "function"
# 	},
# 	{
# 		"inputs": [],
# 		"name": "ReturnRandoms",
# 		"outputs": [
# 			{
# 				"internalType": "uint256[][]",
# 				"name": "",
# 				"type": "uint256[][]"
# 			}
# 		],
# 		"stateMutability": "view",
# 		"type": "function"
# 	},
# 	{
# 		"inputs": [],
# 		"name": "ReturnSecKeys",
# 		"outputs": [
# 			{
# 				"internalType": "uint256[]",
# 				"name": "",
# 				"type": "uint256[]"
# 			}
# 		],
# 		"stateMutability": "view",
# 		"type": "function"
# 	},
# 	{
# 		"inputs": [
# 			{
# 				"internalType": "uint256",
# 				"name": "",
# 				"type": "uint256"
# 			}
# 		],
# 		"name": "SecKeys",
# 		"outputs": [
# 			{
# 				"internalType": "uint256",
# 				"name": "",
# 				"type": "uint256"
# 			}
# 		],
# 		"stateMutability": "view",
# 		"type": "function"
# 	},
# 	{
# 		"inputs": [
# 			{
# 				"internalType": "uint256",
# 				"name": "_secKey",
# 				"type": "uint256"
# 			}
# 		],
# 		"name": "SubmitSecKey",
# 		"outputs": [],
# 		"stateMutability": "nonpayable",
# 		"type": "function"
# 	},
# 	{
# 		"inputs": [
# 			{
# 				"internalType": "uint256",
# 				"name": "_id",
# 				"type": "uint256"
# 			},
# 			{
# 				"internalType": "uint256[2]",
# 				"name": "a",
# 				"type": "uint256[2]"
# 			},
# 			{
# 				"internalType": "uint256[2][2]",
# 				"name": "b",
# 				"type": "uint256[2][2]"
# 			},
# 			{
# 				"internalType": "uint256[2]",
# 				"name": "c",
# 				"type": "uint256[2]"
# 			}
# 		],
# 		"name": "SubmitWinner",
# 		"outputs": [],
# 		"stateMutability": "nonpayable",
# 		"type": "function"
# 	},
# 	{
# 		"inputs": [],
# 		"name": "WinnerBidder",
# 		"outputs": [
# 			{
# 				"internalType": "address",
# 				"name": "",
# 				"type": "address"
# 			}
# 		],
# 		"stateMutability": "view",
# 		"type": "function"
# 	},
# 	{
# 		"inputs": [],
# 		"name": "preHashed",
# 		"outputs": [
# 			{
# 				"internalType": "bytes",
# 				"name": "",
# 				"type": "bytes"
# 			}
# 		],
# 		"stateMutability": "view",
# 		"type": "function"
# 	},
# 	{
# 		"inputs": [],
# 		"name": "test",
# 		"outputs": [
# 			{
# 				"internalType": "bytes",
# 				"name": "",
# 				"type": "bytes"
# 			}
# 		],
# 		"stateMutability": "view",
# 		"type": "function"
# 	},
# 	{
# 		"inputs": [
# 			{
# 				"internalType": "uint256",
# 				"name": "",
# 				"type": "uint256"
# 			}
# 		],
# 		"name": "testPrime",
# 		"outputs": [
# 			{
# 				"internalType": "bytes8",
# 				"name": "",
# 				"type": "bytes8"
# 			}
# 		],
# 		"stateMutability": "view",
# 		"type": "function"
# 	},
# 	{
# 		"inputs": [
# 			{
# 				"components": [
# 					{
# 						"components": [
# 							{
# 								"internalType": "uint256",
# 								"name": "X",
# 								"type": "uint256"
# 							},
# 							{
# 								"internalType": "uint256",
# 								"name": "Y",
# 								"type": "uint256"
# 							}
# 						],
# 						"internalType": "struct Pairing.G1Point",
# 						"name": "a",
# 						"type": "tuple"
# 					},
# 					{
# 						"components": [
# 							{
# 								"internalType": "uint256[2]",
# 								"name": "X",
# 								"type": "uint256[2]"
# 							},
# 							{
# 								"internalType": "uint256[2]",
# 								"name": "Y",
# 								"type": "uint256[2]"
# 							}
# 						],
# 						"internalType": "struct Pairing.G2Point",
# 						"name": "b",
# 						"type": "tuple"
# 					},
# 					{
# 						"components": [
# 							{
# 								"internalType": "uint256",
# 								"name": "X",
# 								"type": "uint256"
# 							},
# 							{
# 								"internalType": "uint256",
# 								"name": "Y",
# 								"type": "uint256"
# 							}
# 						],
# 						"internalType": "struct Pairing.G1Point",
# 						"name": "c",
# 						"type": "tuple"
# 					}
# 				],
# 				"internalType": "struct Verifier.Proof",
# 				"name": "proof",
# 				"type": "tuple"
# 			},
# 			{
# 				"internalType": "uint256[6]",
# 				"name": "input",
# 				"type": "uint256[6]"
# 			}
# 		],
# 		"name": "verifyTx",
# 		"outputs": [
# 			{
# 				"internalType": "bool",
# 				"name": "r",
# 				"type": "bool"
# 			}
# 		],
# 		"stateMutability": "view",
# 		"type": "function"
# 	}
# ];
# provider = ethers.providers.InfuraProvider("kovan", "0090b71f3cbd4212bb37f81b9c3aeaab")

# let privateKey = "5f22a80a0824462fc1ed3b79306696b79dd3ed5dbb9a69287f1aa2cddb4413ef";
# let wallet = new ethers.Wallet(privateKey, provider);
# const contract = new ethers.Contract(contractAddr, contractABI, wallet);

