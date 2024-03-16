// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import "../src/base/RouterImmutables.sol";
import "../src/UniversalRouter.sol";
import "../lib/forge-std/src/interfaces/IERC20.sol";
import "../src/libraries/Commands.sol";
contract V3SwapScript is Script {
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
    bytes path;
    bool userIsPayer = true;
    function setUp() public {
        RouterParameters memory params = RouterParameters(
            weth
        );
        router = address(new UniversalRouter(params));
        path = abi.encodePacked(tokenIn,0x1aEEdD3727A6431b8F070C0aFaA81Cc74f273882,0xfc5A1A6EB076a2C7aD06eD22C90d7E710E35ad0a);
        commands = bytes(abi.encodePacked(bytes1(uint8(Commands.V3_SWAP_EXACT_IN))));
        inputs.push(abi.encode(recipient,amountIn,amountOutMin,path,userIsPayer));        
    }

    function run() public {
        address rich = 	0x84E66f86C28502C0fC8613e1D9CbBEd806F7Adb4;
        vm.prank(rich);
        IERC20(weth).approve(router, type(uint256).max);
        
        // console2.log("before: ", IERC20(usdc).balanceOf(address(96)));
        console2.log("before: ", IERC20(0xfc5A1A6EB076a2C7aD06eD22C90d7E710E35ad0a).balanceOf(address(96)));
        vm.prank(rich);
        UniversalRouter(payable(router)).execute(commands,inputs);
        // console2.log("after: ", IERC20(usdc).balanceOf(address(96)));
        console2.log("before: ", IERC20(0xfc5A1A6EB076a2C7aD06eD22C90d7E710E35ad0a).balanceOf(address(96)));
    }
}
