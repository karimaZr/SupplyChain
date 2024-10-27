pragma solidity ^0.5.0;

contract SupplyChain {
    Order[] public orders;
    mapping(address => uint256[]) public selfOrders;
    enum Statues {
        Created,
        Delivering,
        Delivered,
        Accepted,
        Declined
    }

    struct Order {
        string title;
        string description;
        address supplier;
        address deliveryCompany;
        address customer;
        Statues status;
    }

    event OrderCreated(
        uint256 index,
        address indexed deliveryCompany,
        address indexed customer
    );
    event OrderDelivering(
        uint256 index,
        address indexed supplier,
        address indexed customer
    );
    event OrderDelivered(
        uint256 index,
        address indexed supplier,
        address indexed customer
    );
    event OrderAccepted(
        uint256 index,
        address indexed supplier,
        address indexed deliveryCompany
    );
    event OrderDeclined(
        uint256 index,
        address indexed supplier,
        address indexed deliveryCompany
    );

    modifier onlyOrderDeliveryCompany(uint256 _index) {
        require(orders[_index].deliveryCompany == msg.sender);
        _;
    }
    modifier onlyCustomer(uint256 _index) {
        require(orders[_index].customer == msg.sender);
        _;
    }

    function getOrdersLenght() public view returns (uint256) {
        return orders.length;
    }
    function getSelfOrdersLenght(address _address) public view returns (uint256) {
        return selfOrders[_address].length;
    }

    function getOrder(uint256 _index)
        public
        view
        returns (
            string memory,
            string memory,
            address,
            address,
            address,
            Statues
        )
    {
        Order memory order = orders[_index];
        return (
            order.title,
            order.description,
            order.supplier,
            order.deliveryCompany,
            order.customer,
            order.status
        );
    }

    function craeteOrder(
        string memory _title,
        string memory _description,
        address _deliveryCompany,
        address _customer
    ) public {
        Order memory order = Order({
            title: _title,
            description: _description,
            supplier: msg.sender,
            deliveryCompany: _deliveryCompany,
            customer: _customer,
            status: Statues.Created
        });
        uint256 index = orders.length;
        emit OrderCreated(index, order.deliveryCompany, order.customer);
        orders.push(order);
        selfOrders[msg.sender].push(index);
        selfOrders[_deliveryCompany].push(index);
        selfOrders[_customer].push(index);
    }

    function startDeliveringOrder(uint256 _index)
        public
        onlyOrderDeliveryCompany(_index)
    {
        Order storage order = orders[_index];
        if (order.status != Statues.Created) return;
        emit OrderDelivering(_index, order.supplier, order.customer);
        order.status = Statues.Delivering;
    }

    function stopDeliveringOrder(uint256 _index)
        public
        onlyOrderDeliveryCompany(_index)
    {
        Order storage order = orders[_index];
        if (order.status != Statues.Delivering) return;
        emit OrderDelivered(_index, order.supplier, order.customer);
        order.status = Statues.Delivered;
    }

    function acceptOrder(uint256 _index) public onlyCustomer(_index) {
        Order storage order = orders[_index];
        if (order.status != Statues.Delivered) return;
        emit OrderAccepted(_index, order.supplier, order.deliveryCompany);
        order.status = Statues.Accepted;
    }

    function rejectOrder(uint256 _index) public onlyCustomer(_index) {
        Order storage order = orders[_index];
        emit OrderDeclined(_index, order.supplier, order.deliveryCompany);
        if (order.status != Statues.Delivered) return;
        order.status = Statues.Declined;
    }
}
