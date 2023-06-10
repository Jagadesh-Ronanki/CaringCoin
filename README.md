> Our project is aiming for submission for Chainlink's Spring 2023 Virtual Hackathon. Join us in the Chainlink Spring 2023 Virtual Hackathon, sponsored by Chainlink to create unique solutions to real-world problems using their oracle technology and win prizes! Learn more at https://chain.link/hackathon.

# Project: CaringDAO
**CaringDAO** is a blockchain-based platform that allows you to showcase your skills and creativity in a game-like environment. By creating content similar to a social media platform, you can advance through different levels, earning progressively higher amounts of appreciation for your contributions.

## Problem statement

There are particularly two areas of focus:
1. Applications that incentivize individuals, such as YouTube, Instagram, and Twitter are under monopoly rule, effecting individuals
2. We believe that wide adoption of Web 3 is possible by targeting and incentivizing individuals who provide real value.

Also many people have unique talents and skills that they wish to showcase in public. However, it's not easy to get noticed, and there are very few platforms that actively incentivize contribution. We wanted to make a platform where anyone can be recognized for their skills and creativity.

## Solution we propose
**Caring DAO** introduces a gamified approach to work creation and incentivization through appreciations. Users can register on the platform and choose an image that will later be transformed into an NFT. By participating in the DAO, individuals gain access to a dashboard that provides a comprehensive overview of their actions and contributions.

The platform incorporates advanced technologies such as Filecoin and IPFS to store and retrieve images securely. Users can appreciate the work of others by providing monetary contributions, which are seamlessly processed using **Chainlink USD/ETH price feed** for accurate conversions. As creators receive appreciations, they level up and gain various benefits within the DAO.

**Withdrawal thresholds** are set to ensure that creators accumulate enough appreciations before they can withdraw their earnings. The project also includes a **governance aspect**, where users can participate in voting on proposals and contribute to the decision-making process.

Additionally, Caring DAO allows creators to **mint their own Caring Power tokens**, symbolizing their active participation and dedication to the platform. These tokens serve as a badge of honor and gratitude from the DAO.

### Architecture

![flow1](https://github.com/Jagadesh-Ronanki/CaringDAO/assets/106180776/bc9585ea-d1da-469b-bee6-9f8c097c8dd4)
![flow2](https://github.com/Jagadesh-Ronanki/CaringDAO/assets/106180776/bcdd41db-e0cd-4763-afe5-071e9ff5748f)
![flow5](https://github.com/Jagadesh-Ronanki/CaringDAO/assets/106180776/46df2107-efcb-43c0-82eb-3932918d4767)
![flow3](https://github.com/Jagadesh-Ronanki/CaringDAO/assets/106180776/fd186d88-ea96-4ec0-b701-133e15c06af9)
![flow4](https://github.com/Jagadesh-Ronanki/CaringDAO/assets/106180776/7564b313-5981-415b-af05-54988ab88cdf)
---

By combining decentralized principles, gamification, and incentivization, Caring DAO aims to empower individuals, reward real value, and foster a vibrant and inclusive Web3 ecosystem.

### Technologies
CaringCoin is built on top of the Ethereum blockchain, Deployed on sepolia testnet. Our frontend is developed using React-Vite. For smart contract development, we use Solidity, a widely-used language for blockchain-based contracts. To store images and nft we used **filecoin** and **ipfs** through pinning api's web3.storage and nft.storage

To convert various crypto assets into dollar amounts, we rely on Chainlink price feeds, which provide accurate and reliable conversion values.

### Dependencies
Users interested in using CaringCoin will need to have a compatible Ethereum wallet installed on their device with sepolia testnet eth.

Here's an example scenario of a user starting at level 0 and leveling up to level 1, with a withdrawal limit of 50 dollars and 10% of the amount being considered as a contributable amount to support other users:

    User A signs up for CaringCoin and starts at level 0, with an appreciation amount of $1.

    User A creates a piece of content and shares it with the community. Other users appreciate the content by giving User A cryptocurrency, which increases their appreciation amount.

    After earning enough appreciation, User A levels up to level 1. Their withdrawal limit is now set to $50.

    User A decides to withdraw $50 of their earned cryptocurrency. Of the $50, 10% ($5) is considered as a contributable amount to support other users.

    User A receives the remaining $45 in their wallet.

    Upon reaching level where it aligns with level-to-govern decided by governance. They can mint their nft.
    
    NFT gives you the voting power in DAO and shows your credibility.

<!-- Installation and Usage
To run CaringCoin, clone this repository and install the project dependencies using npm. Once installed, you can run the application from a terminal window using the command npm start.

Additional Resources
To learn more about how to use CaringCoin, including how to create content and earn rewards, please refer to our documentation site at https://[insert URL here]. If you have any questions or need help using the platform, don't hesitate to contact us at [insert email here].

License
CaringCoin is licensed under the MIT License. -->

Demo Video: https://youtu.be/L0gU4ISbyEQ
Try it here: https://main--glittery-dodol-2dd517.netlify.app/

## How to Contribute
We welcome contributions to CaringCoin in any form, including feedback, bug reports, and code contributions. To contribute, please follow these guidelines:

1. Check for issues created / Create a issue
1. Get approval to work on an issue
1. Fork this repository
1. Make your changes in a new branch
1. Submit a pull request to this repository

Once we receive your pull request, we'll review your changes and get back to you as soon as possible. Thanks for your contributions!

Thankyou 🐾
