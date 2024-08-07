# InfinityRSI Trader


## Welcome to InfinityRSI Trader! 🚀

InfinityRSI Trader is an automated trading strategy for MetaTrader 5, utilizing the power of the Relative Strength Index (RSI) to make smart trading decisions. Let's dive into the world of algorithmic trading with a touch of humor and professionalism! 😎

---

## Table of Contents

1. [Introduction](#introduction)
2. [Installation](#installation)
3. [Inputs and Parameters](#inputs-and-parameters)
4. [Features](#features)
5. [How It Works](#how-it-works)
6. [Functions Explained](#functions-explained)
7. [Contact](#contact)
8. [License](#license)

---

## Introduction

Welcome to the InfinityRSI Trader! This bot is designed to make trading decisions based on the RSI values, aiming to buy low and sell high. It's like having a tiny, tireless trader working for you 24/7. 🎉

## Installation

1. Download the `InfinityRSI_Trader.mq5` file.
2. Open MetaTrader 5.
3. Go to `File` -> `Open Data Folder`.
4. Navigate to `MQL5` -> `Experts`.
5. Copy the `InfinityRSI_Trader.mq5` file into the `Experts` folder.
6. Restart MetaTrader 5.
7. Attach the `InfinityRSI_Trader` to a chart.

## Inputs and Parameters

- `RSI_Period`: Number of periods for RSI calculation.
- `RSI_BuyLevel`: RSI level to trigger a buy order.
- `RSI_SellLevel`: RSI level to trigger a sell order.
- `RSI_CloseSellBelow`: RSI level to close sell positions.
- `RSI_CloseBuyAbove`: RSI level to close buy positions.
- `LotSize`: Size of the trading lot.
- `SL_Points`: Stop Loss in points.
- `TP_Points`: Take Profit in points.
- `Trailing_Stop_Points`: Trailing Stop in points.

## Features

- **Automated Trading**: Executes trades based on RSI values.
- **Stop Loss and Take Profit**: Automatically sets SL and TP for each trade.
- **Trailing Stop**: Adjusts SL as the trade becomes profitable.
- **Encapsulated Functions**: Organized code for easy maintenance and upgrades.
- **Humor Mode**: Keeps you entertained while trading. 😉

## How It Works

1. **Initialization**:
   - Sets up the RSI handle.
   - Ensures proper variable initialization.

2. **OnTick Function**:
   - Checks RSI values on each tick.
   - Decides whether to buy, sell, or close positions based on RSI levels.
   - Manages trailing stop loss for open positions.

3. **Trade Management**:
   - **OpenPosition**: Opens a buy/sell position.
   - **ClosePosition**: Closes buy/sell positions.
   - **ManageTrailingStop**: Adjusts trailing stop for open positions.

## Functions Explained

### `OnInit`

Sets up the RSI handle and ensures everything is ready to go. If it fails, it'll let you know with a friendly message. 🎉

### `OnDeinit`

Cleans up by releasing the RSI handle when the expert advisor is removed.

### `OnTick`

The heart of the bot! Executes on every tick:
- Checks RSI values.
- Manages trailing stops.
- Opens and closes positions based on RSI levels.

### `ManageTrailingStop`

Adjusts the stop loss level as the trade becomes profitable. Think of it as your safety net! 🕸️

### `OpenPosition`

Opens a buy or sell position with predefined SL and TP levels. It’s like sending your trading army into battle! 🛡️

### `ClosePosition`

Closes open positions based on the RSI values. Because sometimes, retreat is the best strategy! 🚪

## Contact

Got questions? Feel free to reach out:
- GitHub: https://github.com/phuc-2512
- Email: phanvanphuc25122008@gmail.com
- Linkderdin: https://www.linkedin.com/in/vwnphuc/
- Upwork: https://www.upwork.com/freelancers/~019f361649974209ea

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

Happy trading! May your RSI be ever in your favor. 🎲📈

Feel free to contribute, raise issues, or just drop a line to say hi! Let's make trading fun and profitable together. 🚀
