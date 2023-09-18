// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import {VotingEscrow} from "../VotingEscrow.sol";
import {GaugeController} from "../GaugeController.sol";
import {LendingLedger} from "../LendingLedger.sol";

contract VotingEscrowTest is VotingEscrow {
    constructor() VotingEscrow("VotingEscrow", "VE") {}

    function userVotingPowerDoesNotExceedTotalSupply() public {
        uint256 currentUserPoint = userPointEpoch[msg.sender];
        int128 userVotingPower = userPointHistory[msg.sender][currentUserPoint]
            .bias;

        assert(uint256(uint128(userVotingPower)) <= totalSupply());
    }

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
    address private _owner;

    constructor() GaugeController(address(ve), _govervance) {
        _govervance = msg.sender;
        _owner = msg.sender;
        ve = new VotingEscrow("Voting Escrow", "VE");
    }

    function governanceAddressDoesNotChange() public {
        assert(_govervance == address(_owner));
    }

    function userSlopeNeverLessThan0() public {
        (
            ,
            /*int128 bias*/
            int128 slope_ /*uint256 ts*/,

        ) = ve.getLastUserPoint(msg.sender);

        assert(slope_ >= 0);
    }
}

contract LendingLedgerTest {
    LendingLedger ledger;
    GaugeController gc;
    VotingEscrow ve;
    address _governance;

    uint256 constant WEEK = 7 days;

    constructor() {
        _governance = msg.sender;
        ve = new VotingEscrow("Voting Escrow", "VE");
        gc = new GaugeController(address(ve), _governance);

        ledger = new LendingLedger(address(gc), _governance);
    }

    function lenderBalanceNeverLessThan0(
        address lendingMarket,
        address _lender,
        uint256 lockAmount
    ) public {
        (, , int128 delegated, ) = ve.locked(_lender);
        if (delegated == 0) {
            ve.createLock{value: lockAmount}(lockAmount);
        } else {
            ve.increaseAmount{value: lockAmount}(lockAmount);
        }

        if (!ledger.lendingMarketWhitelist(lendingMarket))
            ledger.whiteListLendingMarket(lendingMarket, true);

        uint256 currEpoch = (block.timestamp / WEEK) * WEEK;
        uint256 lenderBalance = ledger.lendingMarketBalances(
            lendingMarket,
            _lender,
            currEpoch
        );
        assert(lenderBalance >= 0);
    }

    function lendingMarketBalanceNeverLessThan0(address lendingMarket) public {
        if (!ledger.lendingMarketWhitelist(lendingMarket))
            ledger.whiteListLendingMarket(lendingMarket, true);
        uint256 currEpoch = (block.timestamp / WEEK) * WEEK;

        uint256 marketBalance = ledger.lendingMarketTotalBalance(
            lendingMarket,
            currEpoch
        );
        assert(marketBalance >= 0);
    }
}
