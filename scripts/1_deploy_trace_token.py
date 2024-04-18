from brownie import accounts, TextileEcoTraceToken, TextileEcoTraceShop, TextileEcoTrace

initial_supply = 100000000000000000000 

def main():
    account = accounts[0]

    erc20 = TextileEcoTraceToken.deploy(
        account,
        initial_supply, 
        {"from": account}
    )
    tokenShop = TextileEcoTraceShop.deploy(
        erc20,
        {"from": account}
    )
    
    trace = TextileEcoTrace.deploy(
        erc20,
        {"from": account}
    )

    token_amount_to_approve = 100000000000000000000
    erc20.approve(tokenShop.address, token_amount_to_approve, {"from": account})
    erc20.approve(trace.address, token_amount_to_approve, {"from": account})
    
    print('TokenShop ABI', TextileEcoTraceShop.abi)
    print('TokenTrace ABI', TextileEcoTrace.abi)