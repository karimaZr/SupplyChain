const SupplyChain = artifacts.require("./SupplyChain.sol");

contract('SupplyChain', async (accounts) => {
    // Members
    const supplier = accounts[0];
    const deliveryCompany = accounts[1];
    const customer = accounts[2];

    // Order parameters
    const title = 'books';
    const description = "Dictionary";

    const orderIndex = 0;

    it("1. create new order", async () => {
        const instance = await SupplyChain.deployed();



        // Create new order
        await instance.craeteOrder(title, description, deliveryCompany, customer);

        // Get the created order
        const order = await instance.getOrder(orderIndex);
        console.log(order);
        // Assertion
        assert.equal(title, order[0], 'Order title is not correct');
    });
    it("2.start delivering", async () => {
        const instance = await SupplyChain.deployed();
        await instance.startDeliveringOrder(orderIndex, { from: deliveryCompany });
        const order = await instance.getOrder(orderIndex);
        assert.equal(1, order[5], 'state is delivering');
    });
    it("3.stop delivering", async () => {
        const instance = await SupplyChain.deployed();
        await instance.stopDeliveringOrder(orderIndex, { from: deliveryCompany });
        const order = await instance.getOrder(orderIndex);
        assert.equal(2, order[5], 'state is delivred');
    });
    it("4.customer accpet order", async () => {
        const instance = await SupplyChain.deployed();
        await instance.acceptOrder(orderIndex, { from: customer });
        const order = await instance.getOrder(orderIndex);
        assert.equal(3, order[5], 'order accepted ');
    });
    it("5.customer can\'t decline accepted order", async () => {
        const instance = await SupplyChain.deployed();
        try {
            await instance.rejectOrder(orderIndex, { from: customer });
        } catch (err) {
            assert.equal(err.message, 'an\'t decline accepted order');
        }
    });
});
