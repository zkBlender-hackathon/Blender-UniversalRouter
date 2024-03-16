// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import "../src/base/RouterImmutables.sol";
import "../src/UniversalRouter.sol";
import "../lib/forge-std/src/interfaces/IERC20.sol";
import "../src/libraries/Commands.sol";
contract V2SwapScript is Script {
    address router;
    bytes commands;
    bytes[] inputs;
    address weth = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
    address pair = 0x905dfCD5649217c42684f23958568e533C711Aa3;
    address usdc = 0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8;
    address recipient = address(96);
    address tokenIn = weth;
    uint256 amountIn = 1 ether;
    uint256 amountOutMin = 0;
    address[] path;
    uint24[] fee;
    bool userIsPayer = true;
    function setUp() public {
        RouterParameters memory params = RouterParameters(
            weth
        );
        router = address(new UniversalRouter(params));
        path.push(pair);
        fee.push(3000);
        path.push(0x4993E9d7C2C76760Ac1cBd1674D44152a59dAaeD);
        fee.push(3000);
        commands = bytes(abi.encodePacked(bytes1(uint8((Commands.V2_SWAP_EXACT_IN)))));
        inputs.push(abi.encode(recipient,tokenIn,amountIn,amountOutMin,path,fee,userIsPayer));
    }

    function run() public {
        address rich = 	0x84E66f86C28502C0fC8613e1D9CbBEd806F7Adb4;
        vm.prank(rich);
        IERC20(weth).approve(router, type(uint256).max);
        
        // console2.log("before: ", IERC20(usdc).balanceOf(address(96)));
        console2.log("before: ", IERC20(0x11F98c7E42A367DaB4f200d2fdc460fb445CE9a8).balanceOf(address(96)));
        vm.prank(rich);
        UniversalRouter(payable(router)).execute(commands,inputs);
        // console2.log("after: ", IERC20(usdc).balanceOf(address(96)));
        console2.log("before: ", IERC20(0x11F98c7E42A367DaB4f200d2fdc460fb445CE9a8).balanceOf(address(96)));
    }
}
