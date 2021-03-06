// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract WaveRoulette {
    uint256 totalWaves = 0;
    uint256 raffleSize = 3;

    event NewWave(address indexed from, uint256 timestamp, string message);

    event NewWinner(
        address indexed from,
        uint256 timestamp,
        string message,
        Wave[] players,
        Wave lastWave
    );

    struct Wave {
        address waver;
        string message;
        uint256 timestamp;
    }

    Wave[] waves;
    Wave[] rafflePlayers;
    Wave[] winners;
    mapping(address => uint256) public lastWavedAt;

    constructor() payable {}

    function random() private view returns (uint256) {
        return
            uint8(
                uint256(
                    keccak256(
                        abi.encodePacked(block.timestamp, block.difficulty)
                    )
                ) % raffleSize
            );
    }

    function sendPrize(address winner) private {
        uint256 prizeAmount = 0.0001 ether;
        require(
            prizeAmount <= address(this).balance,
            "Trying to withdraw more money than the contract has."
        );
        (bool success, ) = (winner).call{value: prizeAmount}("");
        require(success, "Failed to withdraw money from contract.");
    }

    function pickWinner(Wave memory _newWave) private {
        uint256 index = random();
        Wave memory winner = rafflePlayers[index];
        sendPrize(winner.waver);
        winners.push(Wave(winner.waver, winner.message, winner.timestamp));
        emit NewWinner(
            winner.waver,
            block.timestamp,
            winner.message,
            rafflePlayers,
            _newWave
        );
        delete rafflePlayers;
    }

    function wave(string memory _message) public {
        // require(
        //     lastWavedAt[msg.sender] + 5 seconds < block.timestamp,
        //     "Wait 5 seconds"
        // );

        lastWavedAt[msg.sender] = block.timestamp;
        totalWaves += 1;

        Wave memory newWave = Wave(msg.sender, _message, block.timestamp);
        waves.push(newWave);
        rafflePlayers.push(newWave);

        if (rafflePlayers.length == raffleSize) {
            pickWinner(newWave);
        } else {
            emit NewWave(msg.sender, block.timestamp, _message);
        }
    }

    function getAllWaves() public view returns (Wave[] memory) {
        return waves;
    }

    function getWinners() public view returns (Wave[] memory) {
        return winners;
    }

    function getRafflePlayers() public view returns (Wave[] memory) {
        return rafflePlayers;
    }

    function getTotalWaves() public view returns (uint256) {
        return totalWaves;
    }
}
