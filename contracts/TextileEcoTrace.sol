// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TextileEcoTrace is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    IERC20 public textileEcoTraceToken;

    struct ProductInfo {
        string sku;
        string name;
        string composition;
        string certificates;
        string manufacturingDate;
    }

    mapping(uint256 => ProductInfo) public productInfo;

    constructor(address _textileEcoTraceToken) ERC721("TextileEcoTraceNFT", "TET") {
        textileEcoTraceToken = IERC20(_textileEcoTraceToken);
    }

    function createProduct(
        address recipient, 
        string memory sku,
        string memory name,
        string memory composition,
        string memory certificates,
        string memory manufacturingDate,
        string memory tokenURI, 
        uint256 tokenAmount 
    ) public returns (uint256) {
        require(textileEcoTraceToken.transferFrom(msg.sender, address(this), tokenAmount), "Token transfer failed");
        
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(recipient, newItemId);
        _setTokenURI(newItemId, tokenURI);

        productInfo[newItemId] = ProductInfo(sku, name, composition, certificates, manufacturingDate);

        return newItemId;
    }

    function getProductInfo(uint256 tokenId) public view returns (ProductInfo memory) {
        require(_exists(tokenId), "ProductManagement: Query for nonexistent token");
        return productInfo[tokenId];
    }

    function listAllProducts() public view returns (ProductInfo[] memory) {
        uint256 totalProducts = _tokenIds.current();
        ProductInfo[] memory products = new ProductInfo[](totalProducts);

        for (uint256 i = 0; i < totalProducts; i++) {
            uint256 tokenId = i + 1;
            ProductInfo storage product = productInfo[tokenId];
            products[i] = product;
        }

        return products;
    }

}