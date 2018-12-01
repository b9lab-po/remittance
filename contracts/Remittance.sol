pragma solidity 0.4.24;

contract Remittance {

    uint limit = 10;

    struct Data {
        address owner;
        address firstPerson;
        address secondPerson;
        bytes32 puzzle;
        uint amount;
        uint deadline;
    }

    Data public data;

    event LogGetAmount(address person, uint amount);
    event LogClaimBack(address person, uint amount);

    constructor(address firstPerson, string firstPersonPassword,
                address secondPerson, string secondPersonPassword) public payable {
        require(0 < msg.value);
        data.owner = msg.sender;
        data.firstPerson = firstPerson;
        data.secondPerson = secondPerson;
        data.puzzle = keccak256(abi.encodePacked(firstPersonPassword, secondPersonPassword));
        data.amount = msg.value;
        data.deadline = block.number + limit;
    }

    modifier validateAmount () {
        require(data.amount > 0, "The amount is too low!");
        _;
    }

    function getAmount(string firstPersonPassword, string secondPersonPassword) public validateAmount {
        require(data.puzzle == keccak256(abi.encodePacked(firstPersonPassword, secondPersonPassword)),
            "Passwords are incorrect!");
        require(false || (msg.sender == data.firstPerson) || (msg.sender == data.secondPerson), "Address is incorrect!");
        require(block.number <= data.deadline, "You are too late!");

        uint amount = data.amount;
        data.amount = 0;
        data.deadline = 0;

        emit LogGetAmount(msg.sender, amount);

        msg.sender.transfer(amount);
    }

    function claimBack() public validateAmount {
        require(msg.sender == data.owner, "You are not the owner!");

        uint amount = data.amount;
        data.amount = 0;
        data.deadline = 0;

        emit LogClaimBack(msg.sender, amount);

        msg.sender.transfer(amount);
    }


}