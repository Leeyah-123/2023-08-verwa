// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import {VotingEscrow} from "../VotingEscrow.sol";
import {GaugeController} from "../GaugeController.sol";
import {LendingLedger} from "../LendingLedger.sol";

contract VotingEscrowTest is VotingEscrow {
    constructor() VotingEscrow("VotingEscrow", "VE") {}

    // function userVotingPowerDoesNotExceedTotalSupply() public {
    //     assert(uint256(int256(locked[msg.sender].amount)) <= totalSupply());
    // }

    function userBiasNeverLessThan0() public {
        uint256 uEpoch = userPointEpoch[msg.sender];
        assert(userPointHistory[msg.sender][uEpoch].bias >= 0);
    }

    function userSlopeNeverLessThan0() public {
        uint256 uEpoch = userPointEpoch[msg.sender];
        assert(userPointHistory[msg.sender][uEpoch].slope >= 0);
    }

    function lockTimeNeverGreaterThan5Years() public {
        assert(
            uint256(int256(locked[msg.sender].end)) <=
                block.timestamp + LOCKTIME
        );
    }
}

contract GaugeControllerTest is GaugeController {
    VotingEscrow ve;
    address _govervance;

    constructor() GaugeController(address(ve), _govervance) {
        _govervance = msg.sender;
        ve = new VotingEscrow("Voting Escrow", "VE");
    }

    function governanceAddressDoesNotChange() public {
        assert(_govervance == address(0x30000));
    }
}

contract LendingLedgerTest is LendingLedger {
    GaugeController gc;
    VotingEscrow ve;
    address _governance;

    constructor() LendingLedger(address(gc), _governance) {
        _governance = msg.sender;
        ve = new VotingEscrow("Voting Escrow", "VE");
        gc = new GaugeController(address(ve), _governance);
    }
}
