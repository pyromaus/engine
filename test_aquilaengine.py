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
    # assert aquila_engine.customers(69) is None
    assert aquila_engine.customers(69) == 0


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
    # assert aquila_engine.measureLocations(3) is None
    assert aquila_engine.measureLocations(3) == 0


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
    # add windfarm (custom id)
    tx4 = aquila_engine.addWindFarmE(0, 1, 0, 69, {"from": account})
    assert aquila_engine.windFarms(0)(1) == [0, 1, 0, 69]
    assert aquila_engine.windFarmsIndex(0) == 1

    customer_farm_list = aquila_engine.getAllCustomerWindfarms(0, {"from": account})
    assert customer_farm_list(0) == [0, 0, 0, 100]
    assert customer_farm_list(1) == [0, 1, 0, 69]

    aquila_engine.removeWindFarm(0, 1, {"from": account})
    # assert aquila_engine.windFarms(0)(1) is None
    assert aquila_engine.windFarms(0)(1) == 0


def test_turbine_functions():
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
    # add turbine
    tx4 = aquila_engine.addTurbineI(0, 0, 0, 40, {"from": account})
    assert aquila_engine.turbines(0)(0)(0) == [0, 0, 0, 0, 40]
    assert aquila_engine.turbinesIndex(0)(0) == 0

    # add turbine (custom id)
    aquila_engine.addTurbineE(0, 0, 5, 0, 30, {"from": account})
    assert aquila_engine.turbines(0)(0)(5) == [0, 0, 5, 0, 30]
    assert aquila_engine.turbinesIndex(0)(0) == 5

    turbines_list = aquila_engine.getAllFarmTurbines(0, 0, {"from": account})
    assert turbines_list(0) == [0, 0, 0, 0, 40]
    assert turbines_list(1) == [0, 0, 5, 0, 30]

    aquila_engine.removeTurbine(0, 0, 5, {"from": account})
    # assert aquila_engine.turbines(0, 0, 5) is None
    assert aquila_engine.turbines(0, 0, 5) == 0


def test_wind_functions():
    account = accounts[0]
    aquila_engine = AquilaEngine.deploy({"from": account})

    # add measure location
    coords = "52.115401,4.281019"
    coords_in_bytes32 = aquila_engine.stringToBytes32(coords)
    tx1 = aquila_engine.addMeasureLocationI(coords_in_bytes32, {"from": account})

    # add historical wind avg
    aquila_engine.addHistoricalWindAvg(0, 1000000000, 20, {"from": account})
    assert aquila_engine.historicalWindAvgs(0)(1000000000) == [0, 1000000000, 20]

    # add measured wind
    aquila_engine.addMeasuredWind(0, 1030000000, 25, {"from": account})
    assert aquila_engine.measuredWind(0)(1030000000) == [0, 1030000000, 25]

    # remove historical wind avg
    aquila_engine.removeHistoricalWindAvg(0, 1000000000, {"from": account})
    # assert aquila_engine.historicalWindAvg(0)(1000000000) is None
    assert aquila_engine.historicalWindAvg(0)(1000000000) == 0

    # remove measured wind
    aquila_engine.removeMeasuredWind(0, 1030000000, {"from": account})
    # assert aquila_engine.measuredWind(0)(1030000000) is None
    assert aquila_engine.measuredWind(0)(1030000000) == 0


def test_output_reporting():  # need to talk about the SEQ++
    account = accounts[0]
    aquila_engine = AquilaEngine.deploy({"from": account})

    # add customer
    tx1 = aquila_engine.addCustomerI({"from": account})
    # add windfarm
    tx2 = aquila_engine.addWindFarmI(0, 0, 100, {"from": account})
    # add turbine
    tx3 = aquila_engine.addTurbineI(0, 0, 0, 40, {"from": account})

    # add output report
    aquila_engine.addOutputReport(tx1, tx2, tx3, 1234000000, 42, {"from": account})
    assert aquila_engine.outputReports(tx1)(tx2)(tx3) == [1, 1, 1, 1234000000, 42]

    # remove output report
    aquila_engine.removeOutputReport(tx1, tx2, tx3, {"from": account})
    assert aquila_engine.outputReports(tx1)(tx2)(tx3) == [0, 0, 0, 0, 0]
