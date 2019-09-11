pragma solidity >=0.4.21 <0.6.0;

import "./owner.sol";

contract Prada is Owner {

    event productAdded(uint id, string name);
    event supplierAdded(uint id, string name);
    event orderPlaced(uint orderId, uint qty, uint productId);
    event QCStatus(uint productId, uint qty, string status);

    struct SupplierDetails {
        uint id;
        string name;
        string location;
        uint rank;
        uint productId;
        uint256 createdAt;
    }

    struct ProductDetails {
        uint id;
        string name;
        uint256 quantity;
        uint256 createdAt;
        uint256 deliveryTime;
    }

    struct placeOrder {
        uint id;
        uint256 quantity;
        uint productID;
        uint256 createdAt;
        uint256 deliveryTime;
        uint supplierID;
    }

    struct filteredSupplier {
        uint id;
        uint rank;
    }

    mapping (uint => SupplierDetails) suppliers;
    mapping (uint => ProductDetails) products;
    mapping (uint => placeOrder) orders;
    mapping (uint => filteredSupplier) filSupplier;

    uint supplierCtr;
    uint productCtr;
    uint orderCount;
    uint filSupplierCount;
    uint topRankSupplier = filSupplier[0].rank;
    uint orderedProduct;
    uint orderedQty;

    constructor() public {
        owners = msg.sender;
    }

    //places an order on the network so that suppliers can grab the oppurtunity
    function placeOrderToSuplier(uint _id, uint256 _quantity, uint _productID, uint256 _deliveryTime) public onlyOwner returns (uint supplier) {
        filSupplierCount = filSupplierCount + 1;
        for (uint i = 1; i < supplierCtr; i++) {
            if (suppliers[i].productId == _productID) {
                filSupplier[filSupplierCount].id = suppliers[i].productId;
                filSupplier[filSupplierCount].rank = suppliers[i].rank;
            }
        }

        for (uint p = 1; p < supplierCtr; p++) {
            if (topRankSupplier < filSupplier[p].rank) {
                topRankSupplier = filSupplier[p].rank;
            }
        }

        orderCount = orderCount + 1;
        orders[orderCount].id = _id;
        orders[orderCount].quantity = _quantity;
        orders[orderCount].productID = _productID;
        orders[orderCount].createdAt = now;
        orders[orderCount].deliveryTime = _deliveryTime;
        orders[orderCount].supplierID = topRankSupplier;
        orderedProduct = _productID;
        orderedQty = _quantity;

        emit orderPlaced(_id, _quantity, _productID);

        return topRankSupplier;
    }

    function checkForQC(uint _productId, uint _qty, uint _dobmanf) public onlyOwner returns(string memory status) {
        if (_productId == orderedProduct && orderedQty == _qty && (_dobmanf < now - 30 days)) {
            //to be implemeted based on the history of the supplier for the products delivered in the past
            emit QCStatus(_productId, _qty, "Accepted");
            return "Accepted";
        } else {
            emit QCStatus(_productId, _qty, "Rejected");
            return "Rejected";
        }
    }

    function addSupplier(uint256 _id, string memory _name, string memory _loc, uint _rank, uint _productId) public onlyOwner {
        supplierCtr = supplierCtr + 1;
        suppliers[supplierCtr].id = _id;
        suppliers[supplierCtr].name = _name;
        suppliers[supplierCtr].location = _loc;
        suppliers[supplierCtr].rank = _rank;
        suppliers[supplierCtr].createdAt = now;
        suppliers[supplierCtr].productId = _productId;
        emit supplierAdded(_id, _name);
    }

    function totalSupplierCount() public view onlyOwner returns(uint) {
        return supplierCtr;
    }

    function getSupplier(uint256 _id) public view onlyOwner returns(uint, string memory, string memory, uint, uint) {
        return (suppliers[_id].id, suppliers[_id].name, suppliers[_id].location, suppliers[_id].rank, suppliers[_id].productId);
    }

    function addProduct(uint256 _id, string memory _name, uint256 _qty) public onlyOwner {
        productCtr = productCtr + 1;
        products[productCtr].id = _id;
        products[productCtr].name = _name;
        products[productCtr].quantity = _qty;
        products[productCtr].createdAt = now;
        emit productAdded(_id, _name);
    }

    function totalProductCount() public view onlyOwner returns(uint) {
        return productCtr;
    }

    function getProduct(uint index) public view onlyOwner returns(uint, string memory, uint256, uint256) {
        return (products[index].id, products[index].name, products[index].quantity, products[index].createdAt);
    }
}
