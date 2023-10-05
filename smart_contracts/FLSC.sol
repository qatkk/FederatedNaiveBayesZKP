pragma solidity >=0.8.0 <0.8.7;
import "./BJJ.sol";
import "./verifier.sol" ;

contract FLSC {
    uint32 public number_of_features; 
    uint32 public number_of_entities; 
    uint32 public decryption_rounds = 0; 
    string[] public classes; 
    uint256 funding = 0; 
    uint256 deposit = 0; 
    address[] enitity_address; 
    MVSC ModelVerifier_inst = new MVSC();
    DVSC DecryptVerifier_inst = new DVSC();
    address deployer; 
    uint256[2] public  public_key; 
    mapping (address => bool) is_entities_pubkey_submitted; 
    ///// Model parameters during training 
    mapping (string => uint256[][]) public mu_C;
    mapping (string => uint256[][]) public varience_C;
    mapping (string => uint256[][]) public mu_R;
    mapping (string => uint256[][]) public varience_R;
    ///// Model parameters during decryption 
    mapping (string => uint256[][]) public mu_partial_decrypted;
    mapping (string => uint256[][]) public varience_partial_decrypted;
    mapping (string => bool) class_submitted;
    mapping (string => uint256) submit_count; 
    mapping (address => bool) is_entity_submitted; 
    mapping (address => bool) is_entity_payed; 
    mapping (address => uint32) entity_participation; 

    constructor(uint32 _number_of_entities, uint32 _number_of_features, uint256 _funding, uint256 _deposit){
        deployer = msg.sender;
        enitity_address.push(deployer);
        number_of_features = _number_of_features; 
        number_of_entities = _number_of_entities;
        public_key =[uint256(0),uint256(1)];
        funding = _funding; 
        deposit = _deposit; 
    }
    function submit_entity(address entity) public {
        // require(msg.sender == deployer, "entities must be submitted by the deployer of the contract"); 
        enitity_address.push(entity); 
        is_entities_pubkey_submitted[entity] = false; 
        is_entity_submitted[entity] = true;
        is_entity_payed[entity] = false; 
    }
    function submit_pubkey(uint256 pubkey ) public payable {
        // require(!is_entities_pubkey_submitted[msg.sender] && !is_entity_submitted[msg.sender] , "the public key must not be submitted already"); 
        require(msg.value == funding + deposit); 
        uint[2] memory _pkDecompressed = BJJ.afDecompress(pubkey);
        public_key = BJJ.afAdd(public_key,_pkDecompressed);
        is_entity_payed[msg.sender] = true; 
    }
    function update_model(uint256[4] memory update_point, uint256[4] memory model_point) private view returns(uint256[2] memory) {
        uint256[4] memory result = BJJ.exAdd(update_point, model_point);
        return (BJJ.toAffine(result));
    }
    function submit_update(uint[2] memory a, uint[2][2] memory b, uint[2] memory c, uint256 acccuracy, uint256[][] memory _mu_R, uint256 [][] memory _mu_C , uint256[][] memory vars_R, uint256[][] memory vars_C, string memory class) public {
        // require((_mu_R.length == _mu_C.length  ) &&(_mu_R.length == vars_R.length)&& (_mu_R.length == vars_C.length) &&(_mu_R.length == number_of_features), "Incorrect inputs");
        uint256[24] memory input; 
        MVSC.Proof  memory proof;
        uint[2] memory _temp_point;
        input[0] = acccuracy; 
        proof =  MVSC.Proof(Pairing.G1Point(a[0],a[1]),Pairing.G2Point(b[0],b[1]),Pairing.G1Point(c[0],c[1]));
        uint32 index; 
        for (uint32 input_ = 0; input_ < 4; input_++ ) {
            for (uint32 feature = 0; feature< number_of_features; feature++) { 
                 index = number_of_features * input_  + feature + 1 ;
                 if(input_ == 0 )
                    input[index] = (_mu_R[0][feature]);
                 else if(input_ == 1 )
                    input[index] = (_mu_C[0][feature]);
                 else if(input_ == 2 )
                    input[index] = (vars_R[0][feature]);
                 else if(input_ == 3 )
                    input[index] = (vars_C[0][feature]);
            }
        }
        input[index + 1] = public_key[0];
        input[index + 2] = public_key[1];
        input[index + 3] = uint256(1);
        require(ModelVerifier_inst.verifyTx(proof, input), "Model update must be verified!");
        if (!class_submitted[class]) {
            classes.push(class);
            mu_C[class] = _mu_C; 
            varience_C[class] = vars_C;
            class_submitted[class] = true;
            mu_R [class] = _mu_R;
            varience_R [class] = vars_R;
        }
        else {
            for (uint32 i = 0; i < number_of_features; i++ ) {
                _temp_point = update_model(BJJ.toExtended([_mu_C[0][i], _mu_C[1][i]]), BJJ.toExtended([mu_C[class][0][i], mu_C[class][1][i]]));
                mu_C[class][0][i] = _temp_point[0]; 
                mu_C[class][1][i] = _temp_point[1]; 
                _temp_point = update_model(BJJ.toExtended([vars_C[0][i], vars_C[1][i]]), BJJ.toExtended([varience_C[class][0][i], varience_C[class][1][i]]));
                varience_C[class][0][i] = _temp_point[0];  
                varience_C[class][1][i] = _temp_point[1];  
                _temp_point = update_model( BJJ.toExtended([_mu_R[0][i], _mu_R[1][i]]), BJJ.toExtended([mu_R[class][0][i], mu_R[class][1][i]]));
                mu_R[class][0][i] = _temp_point[0]; 
                mu_R[class][1][i] = _temp_point[1]; 
                _temp_point = update_model(BJJ.toExtended([vars_R[0][i], vars_R[1][i]]), BJJ.toExtended([varience_R[class][0][i], varience_R[class][1][i]]));
                varience_R[class][0][i] = _temp_point[0];  
                varience_R[class][1][i] = _temp_point[1];  
            }
        }
    }
    function start_decryption() public {
        require( msg.sender == deployer, "Only the moderator can call this function!"); 
        uint256 number_of_classes = classes.length;
        for (uint32 i = 0; i< number_of_classes; i++){
            mu_partial_decrypted[classes[i]] = mu_C[classes[i]];
            varience_partial_decrypted[classes[i]] = varience_C[classes[i]];
        }
        decryption_rounds ++;
    }
    function submit_decryption(uint[2] memory a, uint[2][2] memory b, uint[2] memory c, uint256[] memory _C_mean_prime_x, uint256[] memory _C_mean_prime_y, uint256[] memory _C_var_prime_x, uint256[] memory _C_var_prime_y, uint256[2] memory _Pk, string memory class) public{
        DVSC.Proof memory proof;
        proof =  DVSC.Proof(Pairing.G1Point(a[0],a[1]),Pairing.G2Point(b[0],b[1]),Pairing.G1Point(c[0],c[1]));
        uint[33] memory input; 
        uint32 index; 
        for (uint32 input_ = 0; input_ < 6; input_++ ) {
            for (uint32 feature = 0; feature < number_of_features; feature++) { 
                    index = number_of_features * input_  + feature;
                    if(input_ == 0 )
                        input[index] = (mu_R[class][0][feature]);
                    else if(input_ == 1 )
                        input[index] = (mu_partial_decrypted[class][0][feature]);
                    else if(input_ == 2 )
                        input[index] = (_C_mean_prime_x[feature]);
                    else if(input_ == 3 )
                        input[index] = (varience_R[class][0][feature]);
                    else if(input_ == 4 )
                        input[index] = (varience_partial_decrypted[class][0][feature]);
                    else if(input_ == 5 )
                        input[index] = (_C_var_prime_x[feature]);
            }
        }
        input[index + 1] = _Pk[0];
        input[index + 2] = _Pk[1];
        input[index + 3] = uint256(1);
        require(DecryptVerifier_inst.verifyTx(proof, input), "Proof must be verified");
        entity_participation[msg.sender] ++; 
        mu_partial_decrypted[class] = [_C_mean_prime_x, _C_mean_prime_y]; 
        varience_partial_decrypted[class] = [_C_var_prime_x, _C_var_prime_y];
    }
    function return_mu_random(string memory class) public  view returns(uint256[][] memory){
            return mu_R[class];
    }
    function return_varience_random(string memory class) public  view returns(uint256[][] memory){
        return varience_R[class];
    }
    function return_partial_decrypted_mu(string memory class) public  view returns(uint256[][] memory){
        return mu_partial_decrypted[class];
    }
    function return_varience_partial_decrypted(string memory class) public  view returns(uint256[][] memory){
        return varience_partial_decrypted[class];
    }
}