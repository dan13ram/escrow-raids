# LexDAO Escrow
Digital and legal programming for escrows.

## v1 - LexLocker (LXK) ⚖️🔐⚔️ 

LXL stores deal details, permissions, and escrows any ERC-20 token that can be further resolved through lexDAO arbitration for Party B deliverables.

Ethereum mainnet deployment: [0x2CAF5A42EC2D6747eC696714BF913b174d94FDF0](https://etherscan.io/address/0x2CAF5A42EC2D6747eC696714BF913b174d94FDF0#code)

LexDAO Arbitration: [0xB4659D8907cdD36E36D0037F62Ef8Be696e4CE16](https://mainnet.aragon.org/#/lexdaojudge)
> LexDAO Judges (LJ) can each vote to resolve a locked LexLocker.

## v1 - LexGrow (LXG) ⚖️🌱⚔️ 

LXG stores deal details, permissions, and escrows Dai or USDC Stablecoin that can be resolved through lexDAO arbitration for Party B deliverables.  For interest accrual on escrowed Dai or USDC, LXG uses Compound Finance "cToken" wrappers.

The wrapper amount of deposit is paid out. Future implementations will likely output underlying asset and involve additional logic for managing accrued interest. 

Ethereum mainnet deployment: [0x609fee2c94076d2b44f0b1bdb9ebb33877355c5d](https://etherscan.io/address/0x609fee2c94076d2b44f0b1bdb9ebb33877355c5d#code)

LexDAO Arbitration: [0xB4659D8907cdD36E36D0037F62Ef8Be696e4CE16](https://mainnet.aragon.org/#/lexdaojudge)
> LexDAO Judges (LJ) can each vote to resolve a locked LexGrow.

OpenLaw forms that integrate LXG: 

- [COMPOUNDING DEAL LOCKER](https://lib.openlaw.io/web/default/template/Compounding%20Deal%20Locker) 🔐
