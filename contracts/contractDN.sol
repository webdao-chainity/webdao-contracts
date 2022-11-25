// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract contractDN is Ownable{


    uint256 public numberOfShareHolders;

    struct votingInfo{
        string description;
        address currencyAdd;
        uint256 minVoter;
        uint256 maxVoter;
        uint256 startTime;
        uint256 endTime;
        uint256 countYesVoting;
        uint256 countNoVoting;
        uint256 resultVoting;
        bool isComplete;
    }

    struct userVotingInfo{
        bool isVoted;
        uint256 answerVote;
    }

    mapping(uint256 => mapping(address => userVotingInfo)) public voterIdVoting;

    mapping(bytes32 => votingInfo) private votingInfoList;

    mapping(address => bool) public shareHolderList;

    constructor(address[] memory shareHolderArr)
    {
        // shareHolderList[msg.sender] = true;
        for(uint256 i=0; i < shareHolderArr.length; i++){
            shareHolderList[shareHolderArr[i]] = true;
            numberOfShareHolders+=1;
        }
    }

    function addShareHolder(address[] memory shareHolderArr, bool _state) public onlyOwner {
        for(uint256 i=0; i < shareHolderArr.length; i++){
            shareHolderList[shareHolderArr[i]] = _state;
            numberOfShareHolders+=1;
        }
    }

    function deleteShareHolder(address[] memory shareHolderArr, bool _state) public onlyOwner {
        uint256 minShareHolder = numberOfShareHolders - shareHolderArr.length;
        require(minShareHolder > 1,"Error");
        for(uint256 i=0; i < shareHolderArr.length; i++){
            shareHolderList[shareHolderArr[i]] = _state;
            numberOfShareHolders-=1;
        }
    }

    function createVoting(  uint256 _idVoting, bool _isPri, string memory _des,
                            address _cunrrenyAdd,uint256 _minVoter, uint256 _maxVoter,
                            uint256 _startTime, uint256 _endTime) public
    {
        require(shareHolderList[msg.sender] == true,"Error");
        bytes32 _value = keccak256(abi.encodePacked(_idVoting, _isPri));
        votingInfo memory info = votingInfo (
            _des,
            _cunrrenyAdd,
            _minVoter,
            _maxVoter,
            _startTime,
            _endTime,
            0,
            0,
            2,
            false
        );
        votingInfoList[_value] = info;
    }

    function viewVotingById(uint256 _idVoting, bool _isPri)
        public
        view
        returns(string memory,address,uint256,uint256,uint256,uint256,uint256,uint256,uint256,bool)
    {
        bytes32 _value = keccak256(abi.encodePacked(_idVoting, _isPri));
        votingInfo memory info = votingInfoList[_value];
        return (
            info.description,
            info.currencyAdd,
            info.minVoter,
            info.maxVoter,
            info.startTime,
            info.endTime,
            info.countYesVoting,
            info.countNoVoting,
            info.resultVoting,
            info.isComplete
        );
    }

    function getVotingById(uint256 _idVoting, bool _isPri) external view returns (votingInfo memory) {
        bytes32 _value = keccak256(abi.encodePacked(_idVoting, _isPri));
        votingInfo memory info = votingInfoList[_value];
        return info;
    }

    function voterCancelVoting(uint256 _idVoting, bool _isPri, uint256 _vote) public {
        bytes32 _value = keccak256(abi.encodePacked(_idVoting, _isPri));
        require(votingInfoList[_value].isComplete == false, "Voting Is Completed");
        if (_isPri == true)
        {
            require(shareHolderList[msg.sender] == true,"Error ");
            require(voterIdVoting[_idVoting][msg.sender].isVoted == true,"User Does Not Vote");
            voterIdVoting[_idVoting][msg.sender].isVoted = false;
            voterIdVoting[_idVoting][msg.sender].answerVote = 2;
            _subVote(_value, _vote);
        }
        else
        {
            require(voterIdVoting[_idVoting][msg.sender].isVoted == true,"User Does Not Vote");
            voterIdVoting[_idVoting][msg.sender].isVoted = false;
            voterIdVoting[_idVoting][msg.sender].answerVote = 2;
            _subVote(_value, _vote);
        }

    }

    // 0 - No , 1 - Yes
    function votingFunction(uint256 _idVoting, bool _isPri, uint256 _vote) public {
        bytes32 _value = keccak256(abi.encodePacked(_idVoting, _isPri));
        require(votingInfoList[_value].isComplete == false, "Voting Is Completed");

        require(votingInfoList[_value].startTime <= block.timestamp, "Starttime");
        require(votingInfoList[_value].endTime >= block.timestamp, "Endtime");

        if (_isPri == true)
        {
            require(shareHolderList[msg.sender] == true,"Error ");
            require(voterIdVoting[_idVoting][msg.sender].isVoted == false,"Already Voted");
            voterIdVoting[_idVoting][msg.sender].isVoted = true;
            voterIdVoting[_idVoting][msg.sender].answerVote = _vote;
            _addVote(_value, _vote);
        }
        else
        {
            require(voterIdVoting[_idVoting][msg.sender].isVoted == false,"Already Voted");
            voterIdVoting[_idVoting][msg.sender].isVoted = true;
            voterIdVoting[_idVoting][msg.sender].answerVote = _vote;
            _addVote(_value, _vote);
        }
    }

    // deposit
    // IERC20(_token).transferFrom(msg.sender, address(this), _amount);

    // withdraw
    // IERC20(_token).transfer(msg.sender, claimableAmount),

    function _addVote(bytes32 _value, uint256 _vote)
        internal
    {
        if (_vote == 0 )
        {
            votingInfoList[_value].countNoVoting =  votingInfoList[_value].countNoVoting + 1;
        }
        else
        {
            votingInfoList[_value].countYesVoting =  votingInfoList[_value].countYesVoting + 1;
        }
    }

    function _subVote(bytes32 _value, uint256 _vote)
        internal
    {
        if (_vote == 0 )
        {
            votingInfoList[_value].countNoVoting  =  votingInfoList[_value].countNoVoting - 1;
        }
        else
        {
            votingInfoList[_value].countYesVoting =  votingInfoList[_value].countYesVoting - 1;
        }
    }

    function checkConditionVoting(uint256 _idVoting,bool _isPri)
        view
        internal
        returns(bool _isCheck)
    {
        bytes32 _value = keccak256(abi.encodePacked(_idVoting, _isPri));
        uint256 totalVoting = votingInfoList[_value].countYesVoting + votingInfoList[_value].countNoVoting;
        _isCheck = false;
        if (_isPri == true)
        {
            uint256 threshold = totalVoting * 100 / numberOfShareHolders;
            if(threshold > 50) {_isCheck = true;}
        }
        else
        {
            if(votingInfoList[_value].maxVoter <=  totalVoting) {_isCheck = true;}
        }
        return _isCheck;
    }

    function completeVoting(uint256 _idVoting,bool _isPri) public {
        bytes32 _value = keccak256(abi.encodePacked(_idVoting, _isPri));
        require(votingInfoList[_value].isComplete == false, "Voting Is Completed");

        bool isCheck = checkConditionVoting(_idVoting,_isPri);
        require(isCheck == true, "Can Not Complete Voting");

        uint256 totalVoting = votingInfoList[_value].countYesVoting + votingInfoList[_value].countNoVoting;
        uint256 perYes = (votingInfoList[_value].countYesVoting * 100 / totalVoting);
        uint256 perNo = 100 - perYes;
        if (perYes > 50){votingInfoList[_value].resultVoting = 1;}
        if (perNo > 50){votingInfoList[_value].resultVoting = 0;}
        votingInfoList[_value].isComplete = true;
    }

    // function calculateVoting(uint256 _yes, uint256 _no) public pure returns(uint256 _isFlag)
    // {
    //     uint256 totalVoting = _yes + _no ;
    //     uint256 _perYes = (_yes * 100 / totalVoting);
    //     uint256 _perNo = 100 - _perYes;
    //     if (_perYes > 50) {_isFlag = 1;}
    //     if (_perNo > 50) {_isFlag = 0;}
    // }

    function deleteVoting(uint256 _idVoting,bool _isPri) public  {
        bytes32 _value = keccak256(abi.encodePacked(_idVoting, _isPri));
        if ( _isPri == true)
            {
            require(shareHolderList[msg.sender] == true,"Error ");
            delete votingInfoList[_value];
            }
    }
}
