// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import {VotingEscrow} from "../VotingEscrow.sol";
import {GaugeController} from "../GaugeController.sol";
import {LendingLedger} from "../LendingLedger.sol";

contract VotingEscrowTest is VotingEscrow {
    constructor() VotingEscrow("VotingEscrow", "VE") {}

    function lockAmountDoesNotExceedTotalSupply() public {
        assert(uint256(int256(locked[msg.sender].delegated)) <= totalSupply());
    }
}

contract GaugeControllerTest is GaugeController {
    VotingEscrow ve;
    address _govervance;

    constructor() GaugeController(address(ve), _govervance) {
        _govervance = msg.sender;
        ve = new VotingEscrow("Voting Escrow", "VE");
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
