// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ITextileEcoTraceShop {
    function getLatestPrice() external view returns (int);
    function tokenAmount(uint256 amountETH) external view returns (uint256);
}

contract TextileEcoTrace is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    IERC20 public textileEcoTraceToken;
    ITextileEcoTraceShop public textileEcoTraceShop;
        
    struct ProductInfo {
        uint256 id;
        string sku;
        string name;
        string[] compositions;
        string[] certificates; 
        string manufacturingDate;
    }

    uint256 public constant tokenCreationFee = 0.01 ether;

    mapping(uint256 => ProductInfo) public productInfo;

    constructor(
        address _textileEcoTraceToken, 
        address _textileEcoTraceShop
    ) ERC721("TextileEcoTraceNFT", "TET") {
        textileEcoTraceToken = IERC20(_textileEcoTraceToken);
        textileEcoTraceShop = ITextileEcoTraceShop(_textileEcoTraceShop);
    }

    function createProduct(
        address recipient,
        string memory sku,
        string memory name,
        string[] memory compositions, 
        string[] memory initialCertificates,
        string memory manufacturingDate,
        string memory tokenURI
    ) public returns (uint256) {
        uint256 tokensRequired = textileEcoTraceShop.tokenAmount(tokenCreationFee);

        require(textileEcoTraceToken.balanceOf(msg.sender) >= tokensRequired, "Insufficient token balance");
        require(textileEcoTraceToken.transferFrom(msg.sender, address(this), tokensRequired), "Token transfer failed");

        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(recipient, newItemId);
        _setTokenURI(newItemId, tokenURI);

        productInfo[newItemId] = ProductInfo(newItemId, sku, name, compositions, initialCertificates, manufacturingDate);

        return newItemId;
    }

    function removeCertificate(uint256 tokenId, uint256 certificateIndex) public {
        require(_exists(tokenId), "ProductManagement: Query for nonexistent token");
        require(ownerOf(tokenId) == msg.sender, "Caller is not the owner");
        require(certificateIndex < productInfo[tokenId].certificates.length, "Certificate index out of bounds");

        ProductInfo storage product = productInfo[tokenId];
        product.certificates[certificateIndex] = product.certificates[product.certificates.length - 1];
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
