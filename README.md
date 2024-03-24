# Lquix

Lquix is a decentralized finance (DeFi) contract developed on the Ethereum blockchain. It is designed to facilitate liquidity requests and provisions within the ecosystem, leveraging a stable coin (e.g., USDC) for transactions. The contract allows users to request liquidity, which can then be fulfilled by other participants in the ecosystem. Additionally, it incorporates a system for monthly insurance fees to ensure the reliability and sustainability of the service.

## Features

- **Liquidity Requests**: Users can create requests for liquidity, specifying the amount needed.
- **Liquidity Provision**: Participants can fulfill liquidity requests by providing the specified amount, minus a fee.
- **Fee Collection**: A 5% fee is collected on transactions, providing revenue to the contract owner.
- **Insurance Fee**: Users are required to pay a monthly insurance fee, ensuring ongoing participation and reliability.
- **Stable Coin Transactions**: Uses a stable coin (e.g., USDC) for all transactions, providing stability against cryptocurrency volatility.

## Setup

To interact with or deploy the Lquix contract, you will need the following:

1. An Ethereum wallet with Ether for contract deployment and interaction.
2. [Node.js](https://nodejs.org/) and npm installed on your machine.
3. [Truffle Suite](https://www.trufflesuite.com/) for compiling and deploying the contract.
4. The contract address of a stable coin (e.g., USDC) on the Ethereum network.

## How to Use

### Deployment

1. Clone this repository to your local machine.
2. Navigate to the repository directory and install dependencies:

   ```
   npm install
   ```

3. Create a `.env` file and add your Ethereum wallet private key and Infura project ID.
4. Deploy the contract using Truffle:

   ```
   truffle migrate --network <your_network>
   ```

### Interacting with the Contract

You can interact with the contract using [Truffle console](https://www.trufflesuite.com/docs/truffle/getting-started/using-the-console) or integrate it into a web application using [Web3.js](https://web3js.readthedocs.io/).

## Contract Functions

- **createRequest(uint _amount)**: Create a liquidity request.
- **fulfillRequest(uint _requestId)**: Fulfill an existing liquidity request.
- **payMonthlyInsuranceFee()**: Pay the monthly insurance fee to continue participating.

## Development

Feel free to fork the repository and submit pull requests with improvements or extensions to the contract functionalities.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---
