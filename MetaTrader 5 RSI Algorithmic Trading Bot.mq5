//+------------------------------------------------------------------+
//|                                                         test.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link "https://www.mql5.com"
#property version "1.00"

#include <Trade\Trade.mqh> // Bao gồm thư viện giao dịch

// Khai báo các biến đầu vào
input int RSI_Period = 14;              // Số chu kỳ tính RSI
input double RSI_BuyLevel = 30.0;       // Ngưỡng mua RSI
input double RSI_SellLevel = 70.0;      // Ngưỡng bán RSI
input double RSI_CloseSellBelow = 40.0; // Đóng vị thế bán nếu RSI dưới mức này
input double RSI_CloseBuyAbove = 60.0;  // Đóng vị thế mua nếu RSI trên mức này
input double LotSize = 0.1;             // Kích thước lô giao dịch
input double SL_Points = 100;           // Điểm Stop Loss
input double TP_Points = 200;           // Điểm Take Profit
input double Trailing_Stop_Points = 50; // Điểm Trailing Stop

// Khai báo các biến toàn cục
int rsi_handle;
CTrade trade;                 // Đảm bảo biến trade được khai báo đúng cách
datetime last_trade_time = 0; // Thời gian thực hiện giao dịch cuối cùng

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    //--- tạo handle cho chỉ báo RSI
    rsi_handle = iRSI(_Symbol, _Period, RSI_Period, PRICE_CLOSE);
    if (rsi_handle == INVALID_HANDLE)
    {
        Print("Không tạo được handle cho RSI");
        return (INIT_FAILED);
    }
    //---
    return (INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    //--- dọn dẹp
    if (rsi_handle != INVALID_HANDLE)
    {
        IndicatorRelease(rsi_handle);
    }
}
//+------------------------------------------------------------------+
//| Hàm xử lý tick                                                   |
//+------------------------------------------------------------------+
void OnTick()
{
    //--- kiểm tra handle hợp lệ
    if (rsi_handle == INVALID_HANDLE)
        return;

    double rsi_value[1];
    if (CopyBuffer(rsi_handle, 0, 0, 1, rsi_value) < 0)
    {
        Print("Không thể sao chép buffer cho RSI");
        return;
    }

    //--- In giá trị RSI
    Print("Giá trị RSI: ", rsi_value[0]);

    //--- Trailing Stop Loss
    ManageTrailingStop();

    //--- Đóng vị thế bán nếu RSI dưới 40
    if (rsi_value[0] < RSI_CloseSellBelow)
    {
        if (PositionSelect(_Symbol) && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
        {
            if (!ClosePosition(POSITION_TYPE_SELL))
            {
                Print("Lỗi khi đóng vị thế bán");
                return;
            }
            Print("Đóng vị thế bán do RSI dưới ", RSI_CloseSellBelow);
        }
    }

    //--- Đóng vị thế mua nếu RSI trên 60
    if (rsi_value[0] > RSI_CloseBuyAbove)
    {
        if (PositionSelect(_Symbol) && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
        {
            if (!ClosePosition(POSITION_TYPE_BUY))
            {
                Print("Lỗi khi đóng vị thế mua");
                return;
            }
            Print("Đóng vị thế mua do RSI trên ", RSI_CloseBuyAbove);
        }
    }

    //--- Kiểm tra nếu không có lệnh mở nào và thời gian đủ điều kiện để mở giao dịch mới
    if (PositionsTotal() == 0)
    {
        //--- Kiểm tra không có lệnh mở nào trước khi mở giao dịch mới
        if (OpenPositionIfNone(rsi_value[0]))
        {
            last_trade_time = TimeCurrent(); // Cập nhật thời gian giao dịch cuối cùng
        }

        //--- Logic giao dịch dựa trên RSI
        if (rsi_value[0] < RSI_BuyLevel) // Tín hiệu mua
        {
            // Mở mua
            if (OpenPosition(ORDER_TYPE_BUY, LotSize, SL_Points, TP_Points))
            {
                Print("Mở mua do RSI dưới", RSI_BuyLevel);
            }
            else
            {
                Print("Lỗi khi mở vị thế mua");
            }
        }
        else if (rsi_value[0] > RSI_SellLevel) // Tín hiệu bán
        {
            // Mở bán
            if (OpenPosition(ORDER_TYPE_SELL, LotSize, SL_Points, TP_Points))
            {
                Print("Mở bán do RSI trên", RSI_SellLevel);
            }
            else
            {
                Print("Lỗi khi mở vị thế bán");
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Hàm quản lý Trailing Stop Loss                                   |
//+------------------------------------------------------------------+
void ManageTrailingStop()
{
    for (int i = PositionsTotal() - 1; i >= 0; i--)
    {
        if (PositionSelect(PositionGetTicket(i)))
        {
            if (PositionGetString(POSITION_SYMBOL) == _Symbol)
            {
                double price = 0.0;
                double new_sl = 0.0;
                if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
                {
                    price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
                    new_sl = price - Trailing_Stop_Points * _Point;
                    if (new_sl > PositionGetDouble(POSITION_SL))
                    {
                        trade.PositionModify(PositionGetInteger(POSITION_TICKET), new_sl, PositionGetDouble(POSITION_TP));
                        Print("Cập nhật Trailing Stop cho lệnh Mua: ", new_sl);
                    }
                }
                else if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
                {
                    price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
                    new_sl = price + Trailing_Stop_Points * _Point;
                    if (new_sl < PositionGetDouble(POSITION_SL))
                    {
                        trade.PositionModify(PositionGetInteger(POSITION_TICKET), new_sl, PositionGetDouble(POSITION_TP));
                        Print("Cập nhật Trailing Stop cho lệnh Bán: ", new_sl);
                    }
                }
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Hàm mở vị thế                                                     |
//+------------------------------------------------------------------+
bool OpenPosition(int order_type, double volume, double sl_points, double tp_points)
{
    MqlTradeRequest request;
    MqlTradeResult result;
    ulong slippage = 3; // Đảm bảo slippage là kiểu ulong

    ZeroMemory(request);
    ZeroMemory(result);

    request.action = TRADE_ACTION_DEAL;
    request.symbol = _Symbol;
    request.volume = volume;
    request.type = (ENUM_ORDER_TYPE)order_type;
    request.deviation = slippage; // Sử dụng biến slippage kiểu ulong
    request.magic = 0;
    request.comment = "Chiến lược RSI";

    if (order_type == ORDER_TYPE_BUY)
    {
        request.price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
        request.tp = request.price + tp_points * _Point;
        request.sl = request.price - sl_points * _Point;
        request.type_filling = ORDER_FILLING_IOC;
        request.type_time = ORDER_TIME_GTC;
    }
    else if (order_type == ORDER_TYPE_SELL)
    {
        request.price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
        request.tp = request.price - tp_points * _Point;
        request.sl = request.price + sl_points * _Point;
        request.type_filling = ORDER_FILLING_IOC;
        request.type_time = ORDER_TIME_GTC;
    }

    if (!OrderSend(request, result))
    {
        Print("Mở vị thế thất bại: ", result.comment);
        return false;
    }
    Print("Mở vị thế thành công: ", order_type == ORDER_TYPE_BUY ? "Mua" : "Bán");
    return true;
}

//+------------------------------------------------------------------+
//| Hàm đóng vị thế                                                   |
//+------------------------------------------------------------------+
bool ClosePosition(int position_type)
{
    for (int i = PositionsTotal() - 1; i >= 0; i--)
    {
        if (PositionSelect(PositionGetTicket(i)))
        {
            if (PositionGetInteger(POSITION_TYPE) == position_type && PositionGetString(POSITION_SYMBOL) == _Symbol)
            {
                ulong ticket = PositionGetInteger(POSITION_TICKET);
                bool result = trade.PositionClose(ticket);
                if (!result)
                {
                    Print("Đóng vị thế thất bại: ", GetLastError());
                    return false;
                }
                else
                {
                    Print("Đóng vị thế thành công: ", position_type == POSITION_TYPE_BUY ? "Mua" : "Bán");
                    return true;
                }
            }
        }
    }
    return false;
}

//+------------------------------------------------------------------+
//| Hàm mở vị thế nếu không có vị thế nào hiện tại                    |
//+------------------------------------------------------------------+
bool OpenPositionIfNone(double rsi_value)
{
    //--- Kiểm tra nếu không có lệnh mở nào trước khi mở giao dịch mới
    if (PositionsTotal() == 0)
    {
        if (rsi_value < RSI_BuyLevel) // Tín hiệu mua
        {
            // Mở mua
            if (OpenPosition(ORDER_TYPE_BUY, LotSize, SL_Points, TP_Points))
            {
                return true;
            }
            else
            {
                Print("Lỗi khi mở vị thế mua");
            }
        }
        else if (rsi_value > RSI_SellLevel) // Tín hiệu bán
        {
            // Mở bán
            if (OpenPosition(ORDER_TYPE_SELL, LotSize, SL_Points, TP_Points))
            {
                return true;
            }
            else
            {
                Print("Lỗi khi mở vị thế bán");
            }
        }
    }
    return false;
}