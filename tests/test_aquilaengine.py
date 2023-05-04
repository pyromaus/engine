from ape import AquilaEngine, network, config, accounts
import pytest
from web3 import Web3


def test_deploy():
    account = accounts[0]
    aquila_engine = AquilaEngine.deploy({"from": account})
    contract_balance = aquila_engine.getBalance()

    expectedValue = 0
    assert contract_balance == expectedValue
    assert aquila_engine.oracle_jobid() == "0000000001"


def test_customer_functions():
    account = accounts[0]
    aquila_engine = AquilaEngine.deploy({"from": account})

    returned_id = aquila_engine.addCustomerI({"from": account})
    expected_id = 1
    assert expected_id == returned_id
    assert expected_id == aquila_engine.customersIndex(0)

    aquila_engine.addCustomerE(69, {"from": account})
    expected2 = 69

    assert expected2 == aquila_engine.customers(69)
    assert expected2 == aquila_engine.customersIndex(1)

    customer_list = aquila_engine.getAllCustomers({"from": account})
    assert customer_list(0) == 1
    assert customer_list(1) == 69

    aquila_engine.removeCustomer(69, {"from": account})
    assert aquila_engine.customers(69) is None


def test_measure_functions():
    account = accounts[0]
    aquila_engine = AquilaEngine.deploy({"from": account})

    coords = "52.115401,4.281019"
    coords_in_bytes32 = aquila_engine.stringToBytes32(coords)
    location_id = aquila_engine.addMeasureLocationI(
        coords_in_bytes32, {"from": account}
    )
    assert location_id == 1
    assert aquila_engine.measureLocationsIndex(0) == 0

    aquila_engine.addMeasureLocationE(3, coords_in_bytes32, {"from": account})
    assert aquila_engine.measureLocations(3) == [3, coords_in_bytes32]
    assert aquila_engine.measureLocationsIndex(1) == 3

    measure_loc_list = aquila_engine.getAllMeasureLocations({"from": account})
    assert measure_loc_list(0) == [0, coords_in_bytes32]
    assert measure_loc_list(1) == [3, coords_in_bytes32]

    aquila_engine.removeMeasureLocation(3, {"from": account})
    assert aquila_engine.measureLocations(3) is None


def test_windfarm_functions():
    account = accounts[0]
    aquila_engine = AquilaEngine.deploy({"from": account})

    # add customer
    tx1 = aquila_engine.addCustomerI({"from": account})
    # add measure location
    coords = "52.115401,4.281019"
    coords_in_bytes32 = aquila_engine.stringToBytes32(coords)
    tx2 = aquila_engine.addMeasureLocationI(coords_in_bytes32, {"from": account})
    # add windfarm
    tx3 = aquila_engine.addWindFarmI(0, 0, 100, {"from": account})
    assert aquila_engine.windFarms(0)(0) == [0, 0, 0, 100]
    assert aquila_engine.windFarmsIndex(0) == 0

    tx4 = aquila_engine.addWindFarmE(0, 1, 0, 69, {"from": account})
    assert aquila_engine.windFarms(0)(1) == [0, 1, 0, 69]
    assert aquila_engine.windFarmsIndex(0) == 1

    customer_farm_list = aquila_engine.getAllCustomerWindfarms(0, {"from": account})
    assert customer_farm_list(0) == [0, 0, 0, 100]
    assert customer_farm_list(1) == [0, 1, 0, 69]

    aquila_engine.removeWindFarm(0, 1, {"from": account})
    assert aquila_engine.windFarms(0)(1) is None
