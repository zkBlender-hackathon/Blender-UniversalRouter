// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import 'solmate/src/tokens/ERC20.sol';
contract WETH9 is ERC20 {
    event Deposit(address indexed sender, uint256 amount);
    event Withdraw(address indexed sender, uint256 amount);

    constructor() ERC20('Wrap ETH', 'WETH9', 18) {}

    function deposit() public payable {
        _mint(msg.sender, msg.value);
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) public {
        _burn(msg.sender, amount);
        (bool sent, ) = payable(msg.sender).call{value: amount}("");
        require(sent, "Failed to send Ether");
        emit Withdraw(msg.sender, amount);
    }

    receive() external payable {
        deposit();
    }
}
