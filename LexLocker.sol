/*
██╗     ███████╗██╗  ██╗                         
██║     ██╔════╝╚██╗██╔╝                         
██║     █████╗   ╚███╔╝                          
██║     ██╔══╝   ██╔██╗                          
███████╗███████╗██╔╝ ██╗                         
╚══════╝╚══════╝╚═╝  ╚═╝                         
██╗      ██████╗  ██████╗██╗  ██╗███████╗██████╗ 
██║     ██╔═══██╗██╔════╝██║ ██╔╝██╔════╝██╔══██╗
██║     ██║   ██║██║     █████╔╝ █████╗  ██████╔╝
██║     ██║   ██║██║     ██╔═██╗ ██╔══╝  ██╔══██╗
███████╗╚██████╔╝╚██████╗██║  ██╗███████╗██║  ██║
╚══════╝ ╚═════╝  ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝
DEAR MSG.SENDER(S):

/ LXL is a project in beta.
// Please audit and use at your own risk.
/// Entry into LXL shall not create an attorney/client relationship.
//// Likewise, LXL should not be construed as legal advice or replacement for professional counsel.
///// STEAL THIS C0D3SL4W 

~presented by Open, ESQ || LexDAO LLC
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.5.17;

contract Context { // describes current execution context / openzeppelin-contracts/blob/master/contracts/GSN/Context.sol
    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

library SafeMath { // wrappers over solidity arithmetic operations with added overflow checks
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }
    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }
    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;

        return c;
    }
}

library Address { // helper function for address type / openzeppelin-contracts/blob/master/contracts/utils/Address.sol
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }
}

interface IERC20 { // brief interface for erc20 token txs
    function balanceOf(address who) external view returns (uint256);
    
    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

library SafeERC20 { // wrappers around erc20 operations that throw on failure (when the token contract returns false) / openzeppelin-contracts/blob/master/contracts/token/ERC20/SafeERC20.sol
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

   function _callOptionalReturn(IERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: erc20 operation did not succeed");
        }
    }
}

interface IWETH { // brief interface for ether wrapping contract 
    function deposit() payable external;
    function transfer(address dst, uint wad) external returns (bool);
}

contract LexLocker is Context { // digital deal deposits w/ embedded arbitration via LexDAO (lexdao.org)
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    
    /** ADR Wrapper **/
    address public judgeAccessToken;
    address public judgmentRewardToken;
    address payable public lexDAO;
    address public wETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // wrapping contract for raw payable ether
    uint256 public judgeAccessBalance;
    uint256 public judgmentReward;

    /** <$> LXL <$> **/
    address private locker = address(this);
    uint256 public lxl; // index for registered lexlocker
    mapping(uint256 => Deposit) public deposit; 

    struct Deposit {  
        address client; 
        address provider;
        address token;
        uint8 locked;
        uint256 amount;
        uint256 cap;
        uint256 index;
        uint256 released;
        uint256 termination;
        bytes32 details; 
    }
    	
    event DepositToken(address indexed client, address indexed provider, uint256 indexed index);  
    event Release(uint256 indexed index); 
    event Lock(address indexed sender, uint256 indexed index, bytes32 indexed details);
    event PayLexDAO(address indexed sender, uint256 indexed payment, bytes32 indexed details);
    event Resolve(address indexed resolver, uint256 indexed index, bytes32 indexed details); 
    
    constructor(
        address _judgeAccessToken, 
        address _judgmentRewardToken, 
        address payable _lexDAO, 
        uint256 _judgeAccessBalance, 
        uint256 _judgmentReward) public { 
        judgeAccessToken = _judgeAccessToken;
        judgmentRewardToken = _judgmentRewardToken;
        lexDAO = _lexDAO;
        judgeAccessBalance = _judgeAccessBalance;
        judgmentReward = _judgmentReward;
    } 
    
    /***************
    LOCKER FUNCTIONS
    ***************/
    function depositToken( // register lexlocker and deposit token 
        address provider,
        address token,
        uint256 amount, 
        uint256 cap,
        uint256 termination,
        bytes32 details) payable external {
        require(termination >= now, "termination passed");
        
        if (token == wETH && msg.value > 0) {
            require(msg.value == amount, "insufficient ETH");
            IWETH(wETH).deposit();
            (bool success, ) = wETH.call.value(msg.value)("");
            require(success, "transfer failed");
            IWETH(wETH).transfer(address(this), msg.value);
        } else {
            IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        }

        uint256 index = lxl+1; // add to registered index
	    lxl += lxl;
                
            deposit[index] = Deposit( 
                _msgSender(), 
                provider,
                token,
                0,
                amount,
                cap,
                index,
                0,
                termination,
                details);
 
        emit DepositToken(_msgSender(), provider, index); 
    }

    function release(uint256 index) external { // client can transfer deposit to provider
    	Deposit storage depos = deposit[index];
	    
	    require(depos.locked == 0, "deposit locked"); 
    	require(_msgSender() == depos.client, "not client"); 

        IERC20(depos.token).safeTransfer(depos.provider, depos.amount);
        
        depos.released = depos.released+depos.amount;
        
	    emit Release(index); 
    }
    
    function withdraw(uint256 index) external { // withdraw deposit to client if termination time passes
    	Deposit storage depos = deposit[index];
        
        require(depos.locked == 0, "deposit locked"); 
        require(depos.released == 0, "deposit already released"); 
    	require(now >= depos.termination, "deposit time not terminated");
        
        IERC20(depos.token).safeTransfer(depos.client, depos.amount);
        
        depos.released = 1; 
        
	    emit Release(index); 
    }
    
    /************
    ADR FUNCTIONS
    ************/
    function lock(uint256 index, bytes32 details) external { // index client or provider can lock deposit for resolution during locker period
        Deposit storage depos = deposit[index]; 
        
        require(depos.released == 1, "deposit already released"); 
        require(now <= depos.termination, "deposit time already terminated"); 
        require(_msgSender() == depos.client || _msgSender() == depos.provider, "caller not deposit party"); 

	    depos.locked = 1; 
	    
	    emit Lock(_msgSender(), index, details);
    }
    
    function resolve(uint256 index, uint256 clientAward, uint256 providerAward, bytes32 details) external { // judge resolves locked deposit for judgment reward 
        Deposit storage depos = deposit[index];
	    
	    require(depos.locked == 1, "deposit not locked"); 
	    require(depos.released == 0, "deposit already released");
	    require(_msgSender() != depos.client, "resolver cannot be deposit party");
	    require(_msgSender() != depos.provider, "resolver cannot be deposit party");
	    require(clientAward.add(providerAward) == depos.amount, "resolution awards must equal deposit amount");
	    require(IERC20(judgeAccessToken).balanceOf(_msgSender()) >= judgeAccessBalance, "judge token balance insufficient to resolve");
        
        IERC20(depos.token).safeTransfer(depos.client, clientAward);
        IERC20(depos.token).safeTransfer(depos.provider, providerAward);

	    depos.released = 1; 
	    
	    IERC20(judgmentRewardToken).safeTransfer(_msgSender(), judgmentReward);
	    
	    emit Resolve(_msgSender(), index, details);
    }
    
    /*************
    MGMT FUNCTIONS
    *************/
    modifier onlyLexDAO() {
        require(_msgSender() == lexDAO, "caller not lexDAO");
        _;
    }
    
    function payLexDAO(bytes32 details) payable external { // attach ether (Ξ) with details to lexDAO
        (bool success, ) = lexDAO.call.value(msg.value)("");
        require(success, "transfer failed");
        emit PayLexDAO(_msgSender(), msg.value, details);
    }

    function updateJudgeAccessToken(address _judgeAccessToken) external onlyLexDAO { 
        judgeAccessToken = _judgeAccessToken; 
    }
    
    function updateJudgeAccessBalance(uint256 _judgeAccessBalance) external onlyLexDAO {
        judgeAccessBalance = _judgeAccessBalance;
    }
    
    function updateJudgmentRewardToken(address _judgmentRewardToken) external onlyLexDAO { 
        judgmentRewardToken = _judgmentRewardToken;
    }
    
    function updateJudgmentReward(uint256 _judgmentReward) external onlyLexDAO {
        judgmentReward = _judgmentReward;
    }

    function updateLexDAO(address payable _lexDAO) external onlyLexDAO {
        lexDAO = _lexDAO;
    }
}
