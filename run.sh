source .env

# echo $RPC_ALCHEMY
# forge script script/V2Swap.s.sol --rpc-url $ANVIL
# forge script script/V3Swap.s.sol --rpc-url $ANVIL
# forge script script/Deploy.s.sol --rpc-url $ANVIL


forge script script/Deploy.s.sol --rpc-url $ARBITRUM_SEPOLIA --private-key $KEY --broadcast 

# anvil --fork-url $RPC_ALCHEMY --fork-block-number 181444822