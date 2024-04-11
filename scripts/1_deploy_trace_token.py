from brownie import accounts, TextileEcoTraceToken, TextileEcoTraceShop, TextileEcoTrace

initial_supply = 100000000000000000000 

def main():
    account = accounts[0]

    erc20 = TextileEcoTraceToken.deploy(
        account,
        initial_supply, 
        {"from": account}
    )
    TextileEcoTraceShop.deploy(
        erc20,
        {"from": account}
    )
    
    TextileEcoTrace.deploy(
        erc20,
        {"from": account}
    )
    
    print('TokenShop ABI', TextileEcoTraceShop.abi)
    print('TokenTrace ABI', TextileEcoTrace.abi)