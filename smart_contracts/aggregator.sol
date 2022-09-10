pragma solidity >=0.8.0 <0.8.7;
import "./BJJ.sol";
import "./verifier.sol" ;

contract Aggregator {
    bool public verification_status; 
    uint32 public number_of_features; 
    uint32 public number_of_entities; 
    string[] features; 
    string[] classes; 
    uint256[] flat_mu;
    uint256 [84] public temp; 
    address[] public enitity_address; 
    Verifier.Proof public proof;
    address deployer; 
    uint256[2] public  public_key; 
    mapping (string => bool) BidderRegistration;
    mapping (address => bool) is_entities_pubkey_submitted; 
    mapping (string => uint256[][]) public mu;
    mapping (string => bool) class_submitted;
    mapping (string => uint256) submit_count; 
    mapping (string => uint256[][])public varience;
    mapping (address => bool) is_entity_submitted; 
    using Pairing for *;
    constructor(uint32 _number_of_entities, uint32 _number_of_features){
        deployer = msg.sender;
        enitity_address.push(deployer);
        number_of_features = _number_of_features; 
        number_of_entities = _number_of_entities;
        public_key =[uint256(0),uint256(1)];
    }
    function submit_entity(address entity) public {
        // require(msg.sender == deployer, "entities must be submitted by the deployer of the contract"); 
        enitity_address.push(entity); 
        is_entities_pubkey_submitted[entity] = false; 
        is_entity_submitted[entity] = true;
    }
    function submit_pubkey(uint256 pubkey) public {
        // require(!is_entities_pubkey_submitted[msg.sender] && is_entity_submitted , "the public key must not be submitted already"); 
        uint[2] memory _pkDecompressed = BJJ.afDecompress(pubkey);
        public_key = BJJ.afAdd(public_key,_pkDecompressed);
    }
    function submit_update(uint[2] memory a, uint[2][2] memory b, uint[2] memory c, uint256 acccuracy, uint256[][] memory _mu_R, uint256 [][] memory _mu_C , uint256[][] memory vars_R, uint256[][] memory vars_C, string memory class) public {
        require((_mu_R.length == _mu_C.length  ) &&(_mu_R.length == vars_R.length)&& (_mu_R.length == vars_C.length) &&(_mu_R.length == number_of_features), "Incorrect inputs");
        // uint256[] memory input = new uint256[](vars_C.length * 4 * 2 + 2 + 1); 
        uint256[44] memory input; 
        input[0] = acccuracy; 
        proof =  Verifier.Proof(Pairing.G1Point(a[0],a[1]),Pairing.G2Point(b[0],b[1]),Pairing.G1Point(c[0],c[1]));
        for (uint32 input_ = 0; input_ < 4; input_++ ) {
            for (uint32 feature = 0; feature< number_of_features; feature++) { 
                 if(input_ == 0 ){
                    input[number_of_features * input_ * 2 + feature * 2 + 1] = (_mu_R[feature][0]);
                    input[number_of_features * input_ * 2 + feature * 2 + 2] = (_mu_R[feature][1]);
                 }
                 else if(input_ == 1 ){
                    input[number_of_features * input_ * 2 + feature * 2 + 1] = (_mu_C[feature][0]);
                    input[number_of_features * input_ * 2 + feature * 2 + 2] = (_mu_C[feature][1]);
                 }
                 else if(input_ == 2 ){
                    input[number_of_features * input_ * 2 + feature * 2 + 1] = (vars_R[feature][0]);
                    input[number_of_features * input_ * 2 + feature * 2 + 2] = (vars_R[feature][1]);
                 }
                 else if(input_ == 3 ){
                    input[number_of_features * input_ * 2 + feature * 2 + 1] = (vars_C[feature][0]);
                    input[number_of_features * input_ * 2 + feature * 2 + 2] = (vars_C[feature][1]);
                 }
            }
        }
        input[41] = public_key[0];
        input[42] = public_key[1];
        input[43] = uint256(1);
        verification_status = Verifier.verifyTx(proof, input);
        if (class_submitted[class] == false) {
            mu[class] = _mu_C; 
            varience[class] = vars_C;
            class_submitted[class] = true;
        }
        else {
            for (uint32 i = 0; i< number_of_features; i++ ) {
                uint256[4] memory extended_mu = BJJ.toExtended([mu[class][i][0], mu[class][i][1]]);
                uint256[4] memory extended_varience = BJJ.toExtended([varience[class][i][0], varience[class][i][1]]);
                uint256[4] memory extended_mu_update = BJJ.toExtended([_mu_C[i][0], _mu_C[i][1]]);
                uint256[4] memory extended_varience_update = BJJ.toExtended([vars_C[i][0], vars_C[i][1]]);
                uint256[4] memory result_mu = BJJ.exAdd(extended_mu, extended_mu_update);
                uint256[4] memory result_var = BJJ.exAdd(extended_varience, extended_varience_update);
                mu[class][i] = BJJ.toAffine(result_mu); 
                varience[class][i] = BJJ.toAffine(result_var);  
            }
        }
    }
    function decrypt(uint256[5][2] memory _mu, uint256[5][2] memory _varience, string memory class) public{
        // check if the inputs are on the field 
        // if yes save them in the decrypted_mu and decrypted_var : these variables should have the same size as 
        //      the mu and varience of the model and are to be mappings. 
    }
}