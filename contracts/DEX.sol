// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@thirdweb-dev/contracts/base/ERC20Base.sol";

contract DEX is ERC20Base {
    address public token;

    constructor (address _token) ERC20Base(name(), symbol()) {
        token = _token;
    }

    function getTokensInContract() public view returns (uint256) {
        return ERC20Base(token).balanceOf(address(this));
    }

    function addLiquidity(uint256 _amount) public payable returns (uint256) {
        uint256 _liquidity;
        uint256 balanceInEth = address(this).balance;
        uint256 tokenReserve = getTokensInContract();
        ERC20Base _token = ERC20Base(token);

        if (tokenReserve == 0) {
            _token.transferFrom(msg.sender, address(this), _amount);
            _liquidity = balanceInEth;
            _mint(msg.sender, _amount);
        }
        else {
            uint256 reservedEth = balanceInEth - msg.value;
            require(
            _amount >= (msg.value * tokenReserve) / reservedEth,
            "Amount of tokens sent is less than the minimum tokens required"
            );
            _token.transferFrom(msg.sender, address(this), _amount);
        unchecked {
            _liquidity = (totalSupply() * msg.value) / reservedEth;
        }
        _mint(msg.sender, _liquidity);
        }
        return _liquidity;
    }

    function removeLiquidity(uint256 _amount) public returns (uint256, uint256) {
        require(
            _amount > 0, "Amount should be greater than zero"
        );
        uint256 _reservedEth = address(this).balance;
        uint256 _totalSupply = totalSupply();

        uint256 _ethAmount = (_reservedEth * _amount) / totalSupply();
        uint256 _tokenAmount = (getTokensInContract() * _amount) / _totalSupply;
        _burn(msg.sender, _amount);
        payable(msg.sender).transfer(_ethAmount);
        ERC20Base(token).transfer(msg.sender ,_tokenAmount);
        return (_ethAmount, _tokenAmount);
    }

    function getAmountOfTokens(
        uint256 inputAmount,
        uint256 inputReserve,
        uint256 outputReserve
    )
    public pure returns (uint256) 
    {
        require(inputReserve > 0 && outputReserve > 0, "Invalid Reserves");
        // We are charging a fee of `1%`
        // uint256 inputAmountWithFee = inputAmount * 99;
        uint256 inputAmountWithFee = inputAmount;
        uint256 numerator = inputAmountWithFee * outputReserve;
        uint256 denominator = (inputReserve * 100) + inputAmountWithFee;
        unchecked {
            return numerator / denominator;
        }
    }

    function swapEthTotoken() public payable {
        uint256 _reservedTokens = getTokensInContract();
        uint256 _tokensBought = getAmountOfTokens(
            msg.value, 
            address(this).balance, 
            _reservedTokens
        );
        ERC20Base(token).transfer(msg.sender, _tokensBought);
    }

    function swapTokenToEth(uint256 _tokensSold) public {
        uint256 _reservedTokens = getTokensInContract();
        uint256 ethBought = getAmountOfTokens(
            _tokensSold,
            _reservedTokens,
            address(this).balance
        );
        ERC20Base(token).transferFrom(
            msg.sender, 
            address(this), 
            _tokensSold
        );
        payable(msg.sender).transfer(ethBought);
    }
    
}