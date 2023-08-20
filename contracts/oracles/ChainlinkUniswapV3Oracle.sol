// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {BaseOracle} from "./BaseOracle.sol";
import {ChainlinkCollateralAdapter} from "./adapters/ChainlinkCollateralAdapter.sol";
import {UniswapV3BorrowableAdapter} from "./adapters/UniswapV3BorrowableAdapter.sol";

contract ChainlinkUniswapV3Oracle is BaseOracle, ChainlinkCollateralAdapter, UniswapV3BorrowableAdapter {
    constructor(address feed, address pool, uint32 borrowablePriceDelay, uint256 priceScale)
        BaseOracle(priceScale)
        ChainlinkCollateralAdapter(feed)
        UniswapV3BorrowableAdapter(pool, borrowablePriceDelay)
    {}
}
