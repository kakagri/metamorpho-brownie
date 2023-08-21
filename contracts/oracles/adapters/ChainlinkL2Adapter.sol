// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {IChainlinkAggregatorV3} from "./interfaces/IChainlinkAggregatorV3.sol";

contract ChainlinkL2Adapter {
    /// @dev The feed that provides the uptime of the sequencer.
    IChainlinkAggregatorV3 public immutable SEQUENCER_UPTIME_FEED;

    /// @dev Grace period during which the oracle reverts after a sequencer downtime.
    uint256 public immutable GRACE_PERIOD;

    constructor(IChainlinkAggregatorV3 sequencerUptimeFeed, uint256 gracePeriod) {
        require(address(sequencerUptimeFeed) != address(0), "ChainlinkL2Adapter: invalid sequencer uptime feed");
        require(gracePeriod > 0, "ChainlinkL2Adapter: invalid grace period");

        SEQUENCER_UPTIME_FEED = sequencerUptimeFeed;
        GRACE_PERIOD = gracePeriod;
    }
}
