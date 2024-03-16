// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import "../src/base/RouterImmutables.sol";
import "../src/UniversalRouter.sol";
import "../lib/forge-std/src/interfaces/IERC20.sol";
import "../src/libraries/Commands.sol";
import "../src/WETH.sol";
contract V3SwapScript is Script {
    address router;
    address weth;
    function setUp() public {
        vm.startBroadcast();
        weth = address(new WETH9());
        RouterParameters memory params = RouterParameters(
            weth
        );
        router = address(new UniversalRouter(params));
        vm.stopBroadcast();
    }

    function run() public view{
        console2.log("WETH: ", weth);
        console2.log("Universal Router: ", router);
    }
}
