## ShadowFi

### 漏洞原因

`burn()` 函数允许任何人调用燃烧任意地址的代币,导致 LP Pair 合约 $SDT代币被恶意消耗完,用小部分 $SDT 代币就可以掏空池子里的 WBNB.

```solidity
    function burn(address account, uint256 _amount) public {
        _transferFrom(account, DEAD, _amount);

        emit burnTokens(account, _amount);
    }
```

### POC 复现漏洞

[shadowfi-exp.sol](https://github.com/Poor4ever/Some-Defivlun-Exp/blob/main/src/shadowfi-exp.sol) 

```
forge test --contracts "./src/shadowfi.sol" -vvv
```

攻击获利: ~ 1078 WBNB

Attack TX:https://bscscan.com/tx/0xe30dc75253eecec3377e03c532aa41bae1c26909bc8618f21fb83d4330a01018 



## Arbitrage contract

### 漏洞原因

套利合约闪电贷回调函数 `pancakeCall` 没有限制仅 Pair 合约可调用.

[arbitrage_contract-exp.sol](https://github.com/Poor4ever/Some-Defivlun-Exp/blob/main/src/arbitrage_contract-exp.sol) 

### POC 复现漏洞

```
forge test --contracts "./src/arbitrage_contract-exp.sol" -vvv
```

攻击获利: ~ 25912 USDT / ~ 327 WBNB / ~ 5160 BUSD / ~ 0.014 BTCB / ~ 0.097 ETH

Attack TX: https://bscscan.com/tx/0xd48758ef48d113b78a09f7b8c7cd663ad79e9965852e872fdfc92234c3e598d2
