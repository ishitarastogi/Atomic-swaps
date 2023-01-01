pragma solidity ^0.8.4;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract HTLC {
    uint256 public startTime;
    uint256 public lockTime = 10000 seconds;
    string public secret; //abcdefghi
    bytes32 public hash =
        0x34fb2702da7001bf4dbf26a1e4cf31044bd95b85e1017596ee2d23aedc90498b;
    address public recipient;
    address public owner;
    uint256 public amount;
    IERC20 public token;

    constructor(
        address _recepient,
        address _token,
        uint256 _amount
    ) {
        recipient = _recepient;
        owner = msg.sender;
        amount = _amount;
        token = IERC20(_token);
    }

    //fund this contract
    function fund() external {
        startTime = block.timestamp;
        token.transferFrom(msg.sender, address(this), amount);
    }

    function withdraw(string memory _secret) external {
        require(keccak256(abi.encodePacked(_secret)) == hash, "wong secret");
        secret = _secret;
        token.transfer(recipient, amount);
    }

    function refund() external {
        require(block.timestamp > startTime + lockTime, "too early");
        token.transfer(owner, amount);
    }
}
