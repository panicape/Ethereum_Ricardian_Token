pragma solidity 0.4.8;

contract tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, 
    bytes _extraData); }

contract CIMSToken {
    /* Public variables of the token */
    string public standard = 'Token 0.1';
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    address owner;

    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;
    mapping (address => uint256) public creditLine;
    mapping (address => mapping (address => uint256)) public allowance;
    
    mapping (address => uint256) redeemHistory;
    uint256 totalRedeem;

    /* This generates a public event on the blockchain that will notify clients */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /* This notifies clients about the amount burnt */
    event Burn(address indexed from, uint256 value);
    
    event Redeem(address indexed _from, uint256 _value);
    
    struct Providers {
        string _brandname; // the name you are normally known by in the street
        string _shortname; // short name is displayed by trading software, 8 chars
        string _longname; // full legal name
        string _address; // formal address for snail-mail notices
        string _country; // two letter ISO code that indicates the jurisdiction
        string _registration; // legal registration code of the legal person or legal entity
        address _registryBzz; // swarm hash of the signer human readable registry document
    }
    
    Providers [] providerArray;
    
    string voucherTokenBzzSymbol;
    
    address voucherTokenBzzAddr;
    
    
    modifier onlyOwner {
       if (msg.sender != owner) throw; 
       _;
   }
   
   modifier onlyProvider {
       bool check;
       if(balanceOf[msg.sender]!=0) throw; _;
   }

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function MyToken(uint256 initialSupply, string tokenName,
        uint8 decimalUnits, string tokenSymbol) {
        balanceOf[msg.sender] = initialSupply;              // Give the creator all initial tokens
        totalSupply = initialSupply;                        // Update total supply
        name = tokenName;                                   // Set the name for display purposes
        symbol = tokenSymbol;                               // Set the symbol for display purposes
        decimals = decimalUnits;                            // Amount of decimals for display purposes
    }

    /* Send coins */
    function transfer(address _to, uint256 _value) {
        if (_to == 0x0) throw;                               // Prevent transfer to 0x0 address
        if (balanceOf[msg.sender] < _value) throw;           // Check if the sender has enough 
        if (balanceOf[_to] + _value < balanceOf[_to]) throw; // Check for overflows
        balanceOf[msg.sender] -= _value;                     // Subtract from the sender
        balanceOf[_to] += _value;                            // Add the same to the recipient
        Transfer(msg.sender, _to, _value);                   // Notify anyone listening that this transfer took place
    }

    /* Allow another contract to spend some tokens in your behalf */
    function approve(address _spender, uint256 _value)
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    /* Approve and then comunicate the approved contract in a single tx */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }        

    /* A contract attempts to get the coins */
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (_to == 0x0) throw;                                /* Prevent transfer to 0x0 address */
        if (balanceOf[_from] < _value) throw;                 /* Check if the sender has enough */
        if (balanceOf[_to] + _value < balanceOf[_to]) throw;  /* Check for overflows */
        if (_value > allowance[_from][msg.sender]) throw;     /* Check allowance */
        balanceOf[_from] -= _value;                           /* Subtract from the sender */
        balanceOf[_to] += _value;                             /* Add the same to the recipient */
        allowance[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }

    function burn(address _from, uint256 _value) payable returns (bool success) {
        if (balanceOf[_from] < _value) throw;                 /* Check if the sender has enough */
        balanceOf[_from] -= _value;                          /* Subtract from the sender */
        Burn(_from, _value);
        return true;
    }

    function burnFrom(address _from, uint256 _value) payable returns (bool success) {
        if (balanceOf[_from] < _value) throw;                  /* Check if the sender has enough*/
        if (_value > allowance[_from][msg.sender]) throw;   /* Check allowance */
        balanceOf[_from] -= _value;                          /* Subtract from the sender */
        Burn(_from, _value);
        return true;
    }
    
    function addProvider (string _brandname, string _shortname, 
        string memory _longname, string _address, string _country, string _registration, 
        address _registryBzz) {
        
        Providers memory singleProvider = Providers (_brandname,_shortname, _longname, _address, _country, _registration, _registryBzz); 
        providerArray.push(singleProvider);
        
    }
   
    function redeemFrom (address _from, uint256 _value) onlyOwner returns (bool) {
        if (balanceOf[_from] < _value) throw;                 /* Check if the sender has enough*/
        balanceOf[_from] -= _value;                          /* Subtract from the sender */
        redeemHistory[_from] += _value;
        totalRedeem  += _value;
        
        Redeem (_from, _value);
        return true;
    }
    
    function allowPromise(address _spender, uint256 _value) onlyOwner returns (bool) {
        creditLine[msg.sender] = _value;
        return true;
    }
    
    function payCreditLine(address _from, uint256 _value) returns (bool) {
        if(balanceOf[_from] >= _value && balanceOf[_from] != 0 
            && _value <= creditLine[_from]) {
                
            balanceOf[_from] -= _value;
            creditLine[_from] -= _value;
            return true;
        } else {
            return false;
        }
    }

}
