//+------------------------------------------------------------------+
//|                                                  EA_Skeleton.mq4 |
//+------------------------------------------------------------------+

extern int x = 12;
extern int y = 26;
extern int z = 9;
extern int f = 21;

double Lots;



int bm=1;
int sm=2;
//+------------------------------------------------------------------+
int OnInit()
  {

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

  }
//+------------------------------------------------------------------+
void OnTick()
  {
//+----DATA
   double MacdCurrent=iMACD(NULL,0,x,y,z,PRICE_CLOSE,MODE_MAIN,1);
   double SignalCurrent=iMACD(NULL,0,x,y,z,PRICE_CLOSE,MODE_SIGNAL,1);
   
   double MacdPrevious=iMACD(NULL,0,x,y,z,PRICE_CLOSE,MODE_MAIN,2);
   double SignalPrevious=iMACD(NULL,0,x,y,z,PRICE_CLOSE,MODE_SIGNAL,2);
   
   double upperBand=iBands(NULL,0,f,2,0,PRICE_CLOSE,MODE_UPPER,1);
   double lowerBand=iBands(NULL,0,f,2,0,PRICE_CLOSE,MODE_LOWER,1);
   
//+----CLOSE
//close buy
   if(totalBuys(bm)>0)
     {
      if(MacdPrevious<SignalPrevious
      && MacdCurrent<SignalCurrent
      && MacdCurrent<0)
        {
        closeBuy(bm);
        }
     }
//close sell
   if(totalSells(sm)>0)
     {
      if(MacdPrevious>SignalPrevious
      && MacdCurrent>SignalCurrent
      && MacdCurrent>0)
        {
        closeSell(sm);
        }
     }
//+----MM
Lots = 1.0;
//+----OPEN
//open buy
   if(totalBuys(bm)==0)
     {
      if(MacdPrevious>SignalPrevious
      && MacdCurrent>SignalCurrent
      && MacdCurrent>0
      && Low[1]<lowerBand && Close[1]>lowerBand)
        {
        openBuy(Symbol(),Lots,bm);
        }
     }
//open sell
   if(totalSells(sm)==0)
     {
      if(MacdPrevious<SignalPrevious
      && MacdCurrent<SignalCurrent
      && MacdCurrent<0
      && High[1]>upperBand && Close[1]<upperBand)
        {
        openSell(Symbol(),Lots,sm);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void openBuy(string symb,double lot,int magic)
  {
   double tp=0;
   double sl=0;
//double tp=NormalizeDouble(Bid+100*Point,Digits);
//double sl=NormalizeDouble(Bid-100*Point,Digits);
   if(OrderSend(symb,OP_BUY,lot,Ask,3,sl,tp,magic,magic,0,clrNONE))
     {
      Print(Symbol()+" Buy @ "+Ask);
        }else{      Print("Buy Open ERROR");
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void openSell(string symb,double lot,int magic)
  {
   double tp=0;
   double sl=0;
//double tp=NormalizeDouble(Ask-100*Point,Digits);
//double sl=NormalizeDouble(Ask+100*Point,Digits);
   if(OrderSend(symb,OP_SELL,lot,Bid,3,sl,tp,magic,magic,0,clrNONE))
     {
      Print(Symbol()+" Sell @ "+Bid);
        }else{      Print("Sell Open ERROR");
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void closeBuy(int magic)
  {
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(OrderMagicNumber()==magic)
            if(OrderSymbol()==Symbol())
               if(OrderType()==OP_BUY)
                  if(OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,clrNONE))
                    {
                     Print(OrderTicket()+" "+Symbol()+" Buy Closed @ "+OrderClosePrice());
                       }else{      Print("Buy Close Error");
                    }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void closeSell(int magic)
  {
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(OrderMagicNumber()==magic)
            if(OrderSymbol()==Symbol())
               if(OrderType()==OP_SELL)
                  if(OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,clrNONE))
                    {
                     Print(OrderTicket()+" "+Symbol()+" Sell Closed @ "+OrderClosePrice());
                       }else{      Print("Sell Close Error");
                    }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void trailStop(string symb,int stop,int magic)// Symbol + stop in pips + magic number
  {
   double bsl=NormalizeDouble(MarketInfo(symb,MODE_BID)-stop*MarketInfo(symb,MODE_POINT),MarketInfo(symb,MODE_DIGITS));
   double ssl=NormalizeDouble(MarketInfo(symb,MODE_ASK)+stop*MarketInfo(symb,MODE_POINT),MarketInfo(symb,MODE_DIGITS));

   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(OrderMagicNumber()==magic)
            if(OrderSymbol()==symb)

               if(OrderType()==OP_BUY && (OrderStopLoss()<bsl || OrderStopLoss()==0))
                  if(OrderModify(OrderTicket(),OrderOpenPrice(),bsl,OrderTakeProfit(),0,clrNONE))
                    {
                     Print(symb+" Buy's Stop Trailled to "+(string)bsl);
                       }else{
                     Print(symb+" Buy's Stop Trail ERROR");
                    }

      if(OrderType()==OP_SELL && (OrderStopLoss()>ssl || OrderStopLoss()==0))
         if(OrderModify(OrderTicket(),OrderOpenPrice(),ssl,OrderTakeProfit(),0,clrNONE))
           {
            Print(symb+" Sell's Stop Trailled to "+(string)ssl);
              }else{
            Print(symb+" Sell's Stop Trail ERROR");
           }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
int totalBuys(int magic)
  {
   double total=0;
   for(int t=0; t<OrdersTotal(); t++)
     {
      if(OrderSelect(t,SELECT_BY_POS,MODE_TRADES)==true)
        {
         if(OrderMagicNumber()==magic)
            if(OrderSymbol()==Symbol())
              {
               if(OrderType()==OP_BUY)
                  total++;
              }
        }
     }
   return(total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
int totalSells(int magic)
  {
   double total=0;
   for(int t=0; t<OrdersTotal(); t++)
     {
      if(OrderSelect(t,SELECT_BY_POS,MODE_TRADES)==true)
        {
         if(OrderMagicNumber()==magic)
            if(OrderSymbol()==Symbol())
              {
               if(OrderType()==OP_SELL)
                  total++;
              }
        }
     }
   return(total);
  }
//+------------------------------------------------------------------+

