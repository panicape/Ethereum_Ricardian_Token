pragma solidity ^0.4.8;

contract ricardianVoucher {
	// Generic Voucher Language https://tools.ietf.org/html/draft-ietf-trade-voucher-lang-07
	// The Ricardian Financial Instrument Contract 

    /* Public variables of the token */	
    string public standard = 'Token 0.1';
    uint256 public totalSupply;
    string public tokenName;
    uint8 public decimals;
    string public tokenSymbol;
    address public tokenLogo_bzz;  				// swarm hash of a voucher or token icon or logo
    string public provider_name; 			// the name you are normally known by in the street
    string public provider_shortname; 		// short name is displayed by trading software, 8 chars max
    string public provider_longname; 		// full legal name
    string public provider_address; 		// formal address for snail-mail notices
    string public provider_country; 		// two letter ISO code that indicates the jurisdiction
    string public provider_registration; 	// legal registration of the provider (legal person or legal entity)
    address public contract_bzz; 			// swarm hash of the signer human readable contract
    uint8 public issue_date;			// start date for transactions 
    uint8 public validity_start; 			// start date of the contract. Validity period of the voucher to redeem merchandises
    uint8 public validity_end; 				// end date of the contract. Provides restrictions on the validity period of the voucher
    
    // Owner of this contract
    address public owner;
   
     // Balances for each account
    mapping(address => uint256) balances;
  
     // Owner of account approves the transfer of an amount to another account
     mapping(address => mapping (address => uint256)) allowed;
     
     // Functions with this modifier can only be executed by the owner
     modifier onlyOwner() {
         if (msg.sender != owner) {
            throw;
         }
        _;
     }
     
     modifier circulation {
         if (now < issue_date)
             throw;
         _;
     }
     
     modifier beforeCirculation {
         if (now > issue_date)
             throw;
         _;
     }
     
     string[] merchandises; // Provides restrictions on the object to be claimed. Domain-specific meaning of the voucher
     string[] definitions; // Includes terms and definitions that generally desire to be defined in a contract
     string[] conditions; // Provides any other applicable restrictions
     
     /* This generates public events on the blockchain that will notify clients */
     
     // Triggered when tokens are transferred.
     event Transfer(address indexed _from, address indexed _to, uint256 _value);
 
      // Triggered whenever approve(address _spender, uint256 _value) is called.
     event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    
    /* Initializes contract with initial supply tokens to the creator of the contract */
    function ricardianVoucher(
        uint256 _totalSupply,
        string _tokenName,
        uint8 _decimals,
        string _tokenSymbol,
        address _tokenLogo_bzz;
        string _provider_name; 			
        string _provider_shortname; 		
        string _provider_longname; 		
        string _provider_address; 		
        string _provider_country; 		
        string _provider_registration; 	
        address _contract_bzz;
        uint8 _issue_date;
        uint8 _validity_start_inDays; 					// in how many days the period starts
        uint8 _validity_end_inDays; 					// in how many days the period ends	
      
        ) {
    	owner = msg.sender;
        balances[owner] = uint256(initialSupply);       	// Give the creator all initial tokens
        totalSupply = _totalSupply;                        	// Update total supply
        name = _tokenName;                                  // Set the name for display purposes
        symbol = _tokenSymbol;                              // Set the symbol for display purposes
        decimals = _decimals; 								// Amount of decimals for display purposes
        tokenLogo_bzz = _tokenLogo_bzz;
        provider_name = _provider_name;			
        provider_shortname = _provider_shortname;		
        provider_longname = _provider_longname;		
        provider_address = _provider_address;		
        provider_country = _provider_country;		
        provider_registration = _provider_registration;	
        contract_wbzz = _contract_wbzz;
        issue_date = now + _issue_date;
        validity_start = now + _validity_start_inDays * days;
        validity_end = now + _validity_end_inDays * days;         
    }
    
    
    /* write contract terms */
    
    function writeMerchandises (uint8 _number, string _merchandise) onlyOwner beforeCirculation {
    	merchandises[_number] = _merchandise;
    }
    function writeDefinitions (uint8 _number, string _definition) onlyOwner beforeCirculation {
    	definitions[_number] = _definition;
    }
    function writeConditions (uint8 _number, string _condition) onlyOwner beforeCirculation {
    	conditions[_number] = _condition;
    }

    /* Send tokens */
    function transfer(address _to, uint256 _amount) circulation {
        if (balances[msg.sender] >= _amount && _amount > 0) {
            balances[msg.sender] -= _amount;
            balances[_to] += _amount;
            Transfer(msg.sender, _to, _amount);
        } 
    }

    // Allow _spender to withdraw from your account, multiple times, up to the _amount amount.
    // If this function is called again it overwrites the current allowance with _amount.
     function approve(address _spender, uint256 _amount) circulation {
         allowed[msg.sender][_spender] = _amount;
         Approval(msg.sender, _spender, _amount);
    }
     
     // Send _amount amount of tokens from address _from to address _to
     // The transferFrom method is used for a withdraw workflow, allowing contracts to send
     // tokens on your behalf, for example to "deposit" to a contract address and/or to charge
     // fees in sub-currencies; the command should fail unless the _from account has
     // deliberately authorized the sender of the message via some mechanism; we propose
     // these standardized APIs for approval:
     function transferFrom(address _from, address _to, uint256 _amount) circulation {
         //same as above. Replace this line with the following if you want to protect against wrapping uints.
         //if (balances[_from] >= _amount && allowed[_from][msg.sender] >= _amount && balances[_to] + _amount > balances[_to]) {
         if (balances[_from] >= _amount && allowed[_from][msg.sender] >= _amount && _amount > 0) {
             balances[_to] += _amount;
             balances[_from] -= _amount;
             allowed[_from][msg.sender] -= _amount;
             Transfer(_from, _to, _amount);
                      } 
     }

    // What is the balance of a particular account?
     function balanceOf(address _owner) constant returns (uint256 balance) {
         return balances[_owner];
     }

	function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
	    return allowed[_owner][_spender];
	}

    /* This unnamed function is called whenever someone tries to send ether to it */
    function () {
        throw;     // Prevents accidental sending of ether
    }
}
