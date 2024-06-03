pragma solidity ^0.8.0;

contract Mailbox {
    uint public totalLetters;

    function write(string memory letter) public {
        totalLetters++;
        letters.push(Letter(letter, msg.sender));
    }

    //-------
    struct Letter {
        string letter;
        address sender;
    }
    Letter[] private letters;
    //-------
    function read() public view returns (Letter[] memory) {
        return letters;
    }
}
