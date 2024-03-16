// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {IUniswapV2Pair} from "../../../interfaces/IUniswapV2Pair.sol";
import {UniswapV2Library} from "./UniswapV2Library.sol";
// import {UniswapImmutables} from "../UniswapImmutables.sol";
import {Payments} from "../../Payments.sol";
// import {Permit2Payments} from "../../Permit2Payments.sol";
import {Constants} from "../../../libraries/Constants.sol";
import {ERC20} from "solmate/src/tokens/ERC20.sol";

/// @title Router for Uniswap v2 Trades
abstract contract V2SwapRouter is Payments {
    error V2TooLittleReceived();
    error V2TooMuchRequested();
    error V2InvalidPath();

    function _v2Swap(address[] calldata path, uint24[] calldata fee, address recipient, address tokenIn) private {
        unchecked {
            // if (path.length < 2) revert V2InvalidPath();
            uint256 reserveIn;
            uint256 reserveOut;
            address token0;
            address tokenOut;
            uint256 recipientIndex = path.length - 1;
            
            for (uint256 i; i < path.length; i++) {
                token0 = IUniswapV2Pair(path[i]).token0();
                (tokenOut,reserveIn,reserveOut) = UniswapV2Library.tokenOutReservesFor(tokenIn, path[i]);
                uint256 amountIn = ERC20(tokenIn).balanceOf(path[i]) - reserveIn;
                uint256 amountOut = UniswapV2Library.getAmountOut(amountIn, reserveIn, reserveOut,fee[i]);
                (uint256 amount0Out, uint256 amount1Out) =
                    tokenIn == token0 ? (uint256(0), amountOut) : (amountOut, uint256(0));
                address nextPair = i != recipientIndex
                                ? path[i+1]
                                : recipient;
                IUniswapV2Pair(path[i]).swap(amount0Out, amount1Out, nextPair, new bytes(0));
                tokenIn = tokenOut;
            }
        }
    }

    /// @notice Performs a Uniswap v2 exact input swap
    /// @param recipient The recipient of the output tokens
    /// @param amountIn The amount of input tokens for the trade
    /// @param amountOutMinimum The minimum desired amount of output tokens
    /// @param path The path of the trade as an array of token addresses
    /// @param payer The address that will be paying the input
    function v2SwapExactInput(
        address recipient,
        address tokenIn,
        uint256 amountIn,
        uint256 amountOutMinimum,
        address[] calldata path,
        uint24[] calldata fee,
        address payer
    ) internal {
        address firstPair = path[0];
        if (
            amountIn != Constants.ALREADY_PAID // amountIn of 0 to signal that the pair already has the tokens
        ) {
            pay(tokenIn, payer, firstPair, amountIn);
        }

        ERC20 tokenOut = ERC20(UniswapV2Library.getTokenOutMultihop(tokenIn, path));
        uint256 balanceBefore = tokenOut.balanceOf(recipient);

        _v2Swap(path,fee, recipient, tokenIn);

        uint256 amountOut = tokenOut.balanceOf(recipient) - balanceBefore;
        if (amountOut < amountOutMinimum) revert V2TooLittleReceived();
    }

    /// @notice Performs a Uniswap v2 exact output swap
    /// @param recipient The recipient of the output tokens
    /// @param amountOut The amount of output tokens to receive for the trade
    /// @param amountInMaximum The maximum desired amount of input tokens
    /// @param path The path of the trade as an array of token addresses
    /// @param payer The address that will be paying the input
    function v2SwapExactOutput(
        address recipient,
        address tokenOut,
        uint256 amountOut,
        uint256 amountInMaximum,
        address[] calldata path,
        uint24[] calldata fee,
        address payer
    ) internal {
        (address tokenIn, uint256 amountIn) = UniswapV2Library.getAmountInMultihop(tokenOut, amountOut, path, fee);
        if (amountIn > amountInMaximum) revert V2TooMuchRequested();
        pay(tokenIn, payer, path[0], amountIn);
        _v2Swap(path, fee,recipient, tokenIn);
    }
}
