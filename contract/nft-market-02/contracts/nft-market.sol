// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";

contract Market {
    IERC20 public erc20;
    IERC721 public erc721;

    bytes4 internal constant ERC721_RECEIVED = 0x150b7a02;

    // 谁买的，tokenId 是什么，价格是多少
    struct Order {
        address seller;
        uint256 tokenId;
        uint256 price;
    }

    // 为了查询方便，根据 id 查询 Order
    mapping(uint256 => Order) public orderOfId; // token id to order

    // 查询当前交易市场的所有订单
    Order[] public orders;
    mapping(uint256 => uint256) public idToOrderIndex; // token id to idnex in orders

    // 事件（在向链上进行写事件的时候会抛出事件）
    // 成交
    event Deal(address seller, address buyer, uint256 tokenId, uint256 price);
    // 挂单
    event NewOrder(address seller, uint256 tokenId, uint256 price);
    // 改价
    event PriceChanged(
        address seller,
        uint256 tokenId,
        uint256 previousPrice,
        uint256 newPrice
    );
    // 撤单
    event OrderCancelled(address seller, uint256 tokenId);

    constructor(address _erc20, address _erc721) {
        require(_erc20 != address(0), "zero address");
        require(_erc721 != address(0), "zero address");
        erc20 = IERC20(_erc20);
        erc721 = IERC721(_erc721);
    }

    // 购买：购买方转出 USDT，出售方转出 NFT
    function buy(uint256 _tokenId) external {
        address seller = orderOfId[_tokenId].seller;
        address buyer = msg.sender;
        uint256 price = orderOfId[_tokenId].price;
        require(
            erc20.transferFrom(buyer, seller, price),
            "transfer not successful"
        );
        erc721.safeTransferFrom(address(this), buyer, _tokenId);

        removeOrder(_tokenId);

        emit Deal(seller, buyer, _tokenId, price);
    }

    // 取消订单
    function cancelOrder(uint256 _tokenId) external {
        address seller = orderOfId[_tokenId].seller;
        require(msg.sender == seller, "not the seller");
        erc721.safeTransferFrom(address(this), seller, _tokenId);
        removeOrder(_tokenId);
        emit OrderCancelled(seller, _tokenId);
    }

    // 改价格
    function changePrice(uint256 _tokenId, uint256 _newPrice) external {
        address seller = orderOfId[_tokenId].seller;
        require(msg.sender == seller, "not the seller");
        require(_newPrice > 0, "price must be greater than 0");
        uint256 previousPrice = orderOfId[_tokenId].price;
        orderOfId[_tokenId].price = _newPrice;
        Order storage order = orders[idToOrderIndex[_tokenId]];
        // memory 和 storage 区别：storage 存储在链上，memory 存储在内存中
        emit PriceChanged(seller, _tokenId, previousPrice, _newPrice);
        order.price = _newPrice;
        emit PriceChanged(seller, _tokenId, previousPrice, _newPrice);
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4) {
        uint256 price = toUint256(data, 0);
        require(price > 0, "price must be greater than 0");
        Order memory order = Order(from, tokenId, price);
        // 自动上架
        orders.push(Order(from, tokenId, price));
        orderOfId[tokenId] = Order(from, tokenId, price);
        idToOrderIndex[tokenId] = orders.length - 1;
        emit NewOrder(from, tokenId, price);
        return ERC721_RECEIVED;
    }

    function removeOrder(uint256 _tokenId) internal {
        uint256 index = idToOrderIndex[_tokenId];
        uint256 lastIndex = orders.length - 1;
        if (index != lastIndex) {
            Order storage lastOrder = orders[lastIndex];
            orders[index] = lastOrder;
            idToOrderIndex[lastOrder.tokenId] = index;
        }
        orders.pop();
        delete orderOfId[_tokenId];
        delete idToOrderIndex[_tokenId];
    }

    // https://stackoverflow.com/questions/63252057/how-to-use-bytestouint-function-in-solidity-the-one-with-assembly
    function toUint256(
        bytes memory _bytes,
        uint _start
    ) public pure returns (uint256) {
        require(_start + 32 >= _start, "Market: toUint256_overflow");
        require(_bytes.length >= _start + 32, "Market: toUint256_outOfBounds");
        uint256 tempUint;
        assembly {
            tempUint := mload(add(add(_bytes, 0x20), _start))
        }
        return tempUint;
    }
    function getOrderLength() external view returns (uint256) {
        return orders.length;
    }
    function getAllNFTs() external view returns (Order[] memory) {
        return orders;
    }

    
    function getMyNFTs() external view returns (Order[] memory) {
        uint256 length = orders.length;
        uint256 counter = 0;
        for (uint256 i = 0; i < length; i++) {
            if (orders[i].seller == msg.sender) {
                counter++;
            }
        }
        Order[] memory myNFTs = new Order[](counter);
        uint256 index = 0;
        for (uint256 i = 0; i < length; i++) {
            if (orders[i].seller == msg.sender) {
                myNFTs[index] = orders[i];
                index++;
            }
        }
        return myNFTs;
    }
}
