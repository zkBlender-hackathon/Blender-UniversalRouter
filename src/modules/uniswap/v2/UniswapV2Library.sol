// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.0;

import {IUniswapV2Pair} from "../../../interfaces/IUniswapV2Pair.sol";

/// @title Uniswap v2 Helper Library
/// @notice Calculates the recipient address for a command
library UniswapV2Library {
    error InvalidReserves();
    error InvalidPath();

    /// @notice fetches the reserves for each token
    function tokenInReservesFor(address tokenOut, address pair)
        private
        view
        returns (address tokenIn, uint256 reserveA, uint256 reserveB)
    {
        address token0 = IUniswapV2Pair(pair).token0();
        address token1 = IUniswapV2Pair(pair).token1();
        (uint256 reserve0, uint256 reserve1,) = IUniswapV2Pair(pair).getReserves();
        (tokenIn, reserveA, reserveB) = tokenOut == token1 ? (token0, reserve0, reserve1) : (token1, reserve1, reserve0);
    }
    function tokenOutReservesFor(address tokenIn, address pair)
        internal
        view
        returns (address tokenOut, uint256 reserveA, uint256 reserveB)
    {
        address token0 = IUniswapV2Pair(pair).token0();
        address token1 = IUniswapV2Pair(pair).token1();
        (uint256 reserve0, uint256 reserve1,) = IUniswapV2Pair(pair).getReserves();
        (tokenOut, reserveA, reserveB) = tokenIn == token0 ? (token1, reserve0, reserve1) : (token0, reserve1, reserve0);
    }

    /// @notice Given an input asset amount returns the maximum output amount of the other asset
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut, uint24 fee)
        internal
        pure
        returns (uint256 amountOut)
    {
        if (reserveIn == 0 || reserveOut == 0) revert InvalidReserves();
        uint256 amountInWithFee = amountIn * (1e6 - uint256(fee));
        uint256 numerator = amountInWithFee * (reserveOut);
        uint256 denominator = reserveIn * 1e6 + amountInWithFee;
        amountOut = numerator / denominator;
    }

    /// @notice Returns the input amount needed for a desired output amount in a single-hop trade
    function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut, uint24 fee)
        internal
        pure
        returns (uint256 amountIn)
    {
        if (reserveIn == 0 || reserveOut == 0) revert InvalidReserves();
        uint256 numerator = reserveIn * amountOut * 1e6;
        uint256 denominator = (reserveOut - amountOut) * (1e6 - uint256(fee));
        amountIn = (numerator / denominator) + 1;
    }

    /// @notice Returns the input amount needed for a desired output amount in a multi-hop trade
    function getAmountInMultihop(address tokenOut, uint256 amountOut, address[] memory path, uint24[] memory fee)
        internal
        view
        returns (address tokenIn, uint256 amount)
    {
        // if (path.length < 2) revert InvalidPath();
        tokenIn = tokenOut;
        amount = amountOut;
        for (uint256 i = path.length; i > 0; i--) {
            uint256 reserveIn;
            uint256 reserveOut;

            (tokenIn, reserveIn, reserveOut) = tokenInReservesFor(tokenIn, path[i - 1]);
            amount = getAmountIn(amount, reserveIn, reserveOut, fee[i - 1]);
        }
    }

    /// @notice Sorts two tokens to return token0 and token1
    /// @param tokenA The first token to sort
    /// @param tokenB The other token to sort
    /// @return token0 The smaller token by address value
    /// @return token1 The larger token by address value
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
    }

    function getTokenOutMultihop(address tokenIn, address[] memory path) internal view returns (address) {
        address token = tokenIn;
        for (uint256 i = 0; i < path.length; i++) {
            (address token0, address token1) = (IUniswapV2Pair(path[i]).token0(), IUniswapV2Pair(path[i]).token1());
            token = token == token0 ? token1 : token0;
        }
        return token;
    }

    function getTokenInMultihop(address tokenOut, address[] memory path) internal view returns (address) {
        address token = tokenOut;
        for (uint256 i = path.length; i > 0; i--) {
            (address token0, address token1) =
                (IUniswapV2Pair(path[i - 1]).token0(), IUniswapV2Pair(path[i - 1]).token1());
            token = token == token0 ? token1 : token0;
        }
        return token;
    }
}
