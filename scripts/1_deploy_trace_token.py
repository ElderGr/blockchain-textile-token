from brownie import accounts, config, TextileEcoTraceToken

initial_supply = 100000000000000000000 

def main():
    account = accounts[0]

    erc20 = TextileEcoTraceToken.deploy(
        account,
        initial_supply, 
        {"from": account}
    )
    