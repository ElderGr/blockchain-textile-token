// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TextileEcoTrace is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    IERC20 public textileEcoTraceToken;
        
    struct Certificate {
        uint256 id;
        string code;
        string type;
    }

    struct ProductInfo {
        uint256 id;
        string sku;
        string name;
        string composition;
        Certificate[] certificates;
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
        string[] memory compositions, 
        Certificate[] memory initialCertificates,
        string memory manufacturingDate,
        string memory tokenURI,
        uint256 tokenAmount
    ) public returns (uint256) {
        require(textileEcoTraceToken.transferFrom(msg.sender, address(this), tokenAmount), "Token transfer failed");

        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(recipient, newItemId);
        _setTokenURI(newItemId, tokenURI);

        productInfo[newItemId] = ProductInfo(newItemId, sku, name, compositions, initialCertificates, manufacturingDate);

        return newItemId;
    }

    function removeCertificate(uint256 tokenId, uint256 certificateId) public {
        require(_exists(tokenId), "ProductManagement: Query for nonexistent token");
        require(ownerOf(tokenId) == msg.sender, "Caller is not the owner");

        ProductInfo storage product = productInfo[tokenId];
        uint256 indexToRemove = 0;
        bool found = false;

        for (uint256 i = 0; i < product.certificates.length; i++) {
            if (product.certificates[i].id == certificateId) {
                indexToRemove = i;
                found = true;
                break;
            }
        }

        require(found, "Certificate not found");

        product.certificates[indexToRemove] = product.certificates[product.certificates.length - 1];
        product.certificates.pop();
    }


    function addCertificates(uint256 tokenId, string[] memory newCertificates) public {
        require(_exists(tokenId), "ProductManagement: Query for nonexistent token");
        require(ownerOf(tokenId) == msg.sender, "Caller is not the owner");

        ProductInfo storage product = productInfo[tokenId];
        for (uint i = 0; i < newCertificates.length; i++) {
            product.certificates.push(newCertificates[i]);
        }
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